import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/task_provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../utils/helpers.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _contactNameController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _deadlineController = TextEditingController();
  String? _assignedUserId;
  DateTime? _deadlineAt;
  String _deadlineMode = 'hours';
  int _deadlineHours = 24;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().loadUsers();
    });
    _applyHoursDeadline();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _contactNameController.dispose();
    _contactPhoneController.dispose();
    _descriptionController.dispose();
    _deadlineController.dispose();
    super.dispose();
  }

  void _applyHoursDeadline() {
    final deadline = DateTime.now().add(Duration(hours: _deadlineHours));
    _deadlineAt = deadline;
    _deadlineController.text =
        '${_deadlineHours}h from now (${Helpers.formatDateTime(deadline)})';
  }

  Future<void> _pickDeadlineDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate:
          _deadlineAt != null && _deadlineAt!.isAfter(now) ? _deadlineAt! : now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_deadlineAt ?? now),
    );
    if (time == null) return;

    final selected = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    if (selected.isBefore(now)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Deadline must be in the future'),
          backgroundColor: Colors.red.shade600,
        ),
      );
      return;
    }

    setState(() {
      _deadlineAt = selected;
      _deadlineController.text = Helpers.formatDateTime(selected);
    });
  }

  Future<void> _createTask() async {
    if (!_formKey.currentState!.validate()) return;
    if (_assignedUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a team member',
              style: TextStyle(fontSize: sw(context, 14))),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(sw(context, 16)),
          padding: EdgeInsets.symmetric(
              horizontal: sw(context, 16), vertical: sh(context, 12)),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(sw(context, 10))),
        ),
      );
      return;
    }
    if (_deadlineAt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please choose a deadline',
              style: TextStyle(fontSize: sw(context, 14))),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(sw(context, 16)),
          padding: EdgeInsets.symmetric(
              horizontal: sw(context, 16), vertical: sh(context, 12)),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(sw(context, 10))),
        ),
      );
      return;
    }

    final taskProvider = context.read<TaskProvider>();
    final success = await taskProvider.createTask({
      'title': _titleController.text.trim(),
      'location': _locationController.text.trim(),
      'contactName': _contactNameController.text.trim(),
      'contactPhone': _contactPhoneController.text.trim(),
      'description': _descriptionController.text.trim(),
      'assignedTo': _assignedUserId,
      'deadlineAt': _deadlineAt!.toIso8601String(),
    });

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task created successfully',
                style: TextStyle(fontSize: sw(context, 14))),
            backgroundColor: AppConstants.completedColor,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(sw(context, 16)),
            padding: EdgeInsets.symmetric(
                horizontal: sw(context, 16), vertical: sh(context, 12)),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(sw(context, 10))),
          ),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              taskProvider.error ?? 'Failed to create task',
              style: TextStyle(fontSize: sw(context, 14)),
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(sw(context, 16)),
            padding: EdgeInsets.symmetric(
                horizontal: sw(context, 16), vertical: sh(context, 12)),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(sw(context, 10))),
          ),
        );
      }
    }
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) return 'This field is required';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final users = context
        .watch<UserProvider>()
        .salesUsers
        .where((u) => u.isActive)
        .toList();

    return Scaffold(
      backgroundColor: AppConstants.surfaceColor,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text(
          'Create Task',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, size: 28),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppConstants.textPrimary.withOpacity(0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppConstants.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.add_task_rounded,
                            size: 20, color: AppConstants.primaryColor),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Task Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppConstants.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  CustomTextField(
                    controller: _titleController,
                    label: 'Task Title',
                    hint: 'e.g. Repair at Model Town',
                    prefixIcon: Icons.title_rounded,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                    validator: _required,
                  ),
                  const SizedBox(height: 24),
                  CustomTextField(
                    controller: _locationController,
                    label: 'Location / Address',
                    hint: 'e.g. 123 Main Street, Model Town',
                    prefixIcon: Icons.location_on_rounded,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                    validator: _required,
                  ),
                  const SizedBox(height: 24),
                  CustomTextField(
                    controller: _contactNameController,
                    label: 'Contact Person Name',
                    hint: 'e.g. John Doe',
                    prefixIcon: Icons.person_rounded,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                    validator: _required,
                  ),
                  const SizedBox(height: 24),
                  CustomTextField(
                    controller: _contactPhoneController,
                    label: 'Contact Phone Number',
                    hint: 'e.g. +1 234 567 890',
                    prefixIcon: Icons.phone_rounded,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                    validator: _required,
                  ),
                  const SizedBox(height: 24),
                  CustomTextField(
                    controller: _descriptionController,
                    label: 'Description / Notes',
                    hint: 'What needs to be done?',
                    prefixIcon: Icons.notes_rounded,
                    maxLines: 4,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _createTask(),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 8),
                    child: Text(
                      'ASSIGN TO'.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: AppConstants.textTertiary,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  DropdownButtonFormField<String>(
                    value: _assignedUserId,
                    items: users
                        .map(
                          (u) => DropdownMenuItem(
                            value: u.id,
                            child: Text('${u.name} (${u.email})'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _assignedUserId = value),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.assignment_ind_rounded),
                      hintText: users.isEmpty
                          ? 'No active team members available'
                          : 'Select team member',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide:
                            const BorderSide(color: AppConstants.dividerColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide:
                            const BorderSide(color: AppConstants.dividerColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                            color: AppConstants.primaryColor, width: 2),
                      ),
                      contentPadding: const EdgeInsets.all(20),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 8),
                    child: Text(
                      'DEADLINE TYPE'.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: AppConstants.textTertiary,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('Hours From Now'),
                          selected: _deadlineMode == 'hours',
                          onSelected: (_) {
                            setState(() {
                              _deadlineMode = 'hours';
                              _applyHoursDeadline();
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('Pick Date & Time'),
                          selected: _deadlineMode == 'datetime',
                          onSelected: (_) {
                            setState(() {
                              _deadlineMode = 'datetime';
                              if (_deadlineAt != null) {
                                _deadlineController.text =
                                    Helpers.formatDateTime(_deadlineAt!);
                              }
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_deadlineMode == 'hours')
                    DropdownButtonFormField<int>(
                      value: _deadlineHours,
                      items: const [4, 8, 12, 24, 48, 72]
                          .map(
                            (hours) => DropdownMenuItem(
                              value: hours,
                              child: Text('$hours hours'),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          _deadlineHours = value;
                          _applyHoursDeadline();
                        });
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: const Icon(Icons.timer_rounded),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                              color: AppConstants.dividerColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                              color: AppConstants.dividerColor),
                        ),
                        contentPadding: const EdgeInsets.all(20),
                      ),
                    ),
                  if (_deadlineMode == 'datetime')
                    CustomTextField(
                      controller: _deadlineController,
                      label: 'Deadline Date & Time',
                      hint: 'Tap to choose date and time',
                      prefixIcon: Icons.event_rounded,
                      readOnly: true,
                      onTap: _pickDeadlineDateTime,
                    ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppConstants.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.schedule_rounded,
                            size: 16, color: AppConstants.primaryColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _deadlineAt == null
                                ? 'No deadline selected'
                                : 'Deadline: ${Helpers.formatDateTime(_deadlineAt!)}',
                            style: const TextStyle(
                              color: AppConstants.primaryColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  Consumer<TaskProvider>(
                    builder: (context, taskProvider, _) {
                      return CustomButton(
                        text: 'PROCEED & CREATE',
                        onPressed: _createTask,
                        isLoading: taskProvider.isLoading,
                        icon: Icons.rocket_launch_rounded,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
