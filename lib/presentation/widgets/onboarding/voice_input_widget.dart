import 'package:flutter/material.dart';
import 'package:unified_storefronts/core/utils/voice_to_text_helper.dart';

class VoiceInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final int? maxLines;
  final int? maxLength;
  final Function(String)? onChanged;
  final String? initialText;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final bool autoFocus;
  final TextInputType keyboardType;

  const VoiceInputWidget({
    super.key,
    required this.controller,
    this.label = '',
    this.hintText = 'Start speaking...',
    this.maxLines = 1,
    this.maxLength,
    this.onChanged,
    this.initialText,
    this.validator,
    this.focusNode,
    this.autoFocus = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  State<VoiceInputWidget> createState() => _VoiceInputWidgetState();
}

class _VoiceInputWidgetState extends State<VoiceInputWidget> {
  final VoiceToTextHelper _voiceHelper = VoiceToTextHelper();
  bool _isListening = false;
  String _recognizedText = '';
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeVoiceHelper();
    
    // Set initial text if provided
    if (widget.initialText != null && widget.initialText!.isNotEmpty) {
      widget.controller.text = widget.initialText!;
      _recognizedText = widget.initialText!;
    }
  }

  @override
  void dispose() {
    _voiceHelper.dispose();
    super.dispose();
  }

  Future<void> _initializeVoiceHelper() async {
    try {
      await _voiceHelper.initialize();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initialize voice recognition: $e';
      });
    }
  }

  Future<void> _toggleListening() async {
    if (!_voiceHelper.isAvailable) {
      await _initializeVoiceHelper();
      if (!_voiceHelper.isAvailable) {
        setState(() {
          _errorMessage = 'Speech recognition not available on this device.';
        });
        return;
      }
    }

    if (_isListening) {
      await _voiceHelper.stopListening();
      setState(() {
        _isListening = false;
      });
    } else {
      setState(() {
        _errorMessage = '';
        _isListening = true;
      });
      
      final success = await _voiceHelper.startListening(
        onResult: (text) {
          setState(() {
            _recognizedText = text;
            // Update the text controller
            widget.controller.text = text;
            
            // Trigger onChanged callback if provided
            if (widget.onChanged != null) {
              widget.onChanged!(text);
            }
          });
        },
        onDone: () {
          setState(() {
            _isListening = false;
          });
        },
      );
      
      if (!success) {
        setState(() {
          _isListening = false;
          _errorMessage = 'Failed to start voice recognition.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label.isNotEmpty) ...[
          Text(
            widget.label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
        ],
        
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text field
            Expanded(
              child: TextFormField(
                controller: widget.controller,
                focusNode: widget.focusNode,
                autofocus: widget.autoFocus,
                maxLines: widget.maxLines,
                maxLength: widget.maxLength,
                keyboardType: widget.keyboardType,
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: 16.0,
                  ),
                ),
                validator: widget.validator,
                onChanged: widget.onChanged,
              ),
            ),
            
            // Voice input button
            Container(
              height: 56,
              margin: const EdgeInsets.only(left: 8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isListening 
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.primary,
              ),
              child: IconButton(
                icon: Icon(
                  _isListening ? Icons.stop : Icons.mic,
                  color: Colors.white,
                ),
                onPressed: _toggleListening,
              ),
            ),
          ],
        ),
        
        // Show error message if any
        if (_errorMessage.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            _errorMessage,
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontSize: 14,
            ),
          ),
        ],
        
        // Show listening status
        if (_isListening) ...[
          const SizedBox(height: 8),
          const Row(
            children: [
              Icon(
                Icons.mic,
                color: Colors.red,
                size: 16,
              ),
              SizedBox(width: 8),
              Text(
                'Listening...',
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}