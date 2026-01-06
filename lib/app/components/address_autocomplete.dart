import 'dart:developer';
import 'package:firebase_google_apple_notif/app/styles/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddressResult {
  AddressResult({
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.placeId,
  });
  final String address;
  final double latitude;
  final double longitude;
  final String placeId;
}

class AddressAutocompleteTextField extends StatefulWidget {
  const AddressAutocompleteTextField({
    required this.apiKey,
    super.key,
    this.controller,
    this.hint,
    this.label = false,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.words,
    this.textInputAction = TextInputAction.done,
    this.textAlign = TextAlign.start,
    this.maxLength,
    this.validator,
    this.autovalidateMode,
    this.onSaved,
    this.initialValue,
    this.readOnly = false,
    this.borderRadius = 16.0,
    this.onAddressSelected,
  });

  final TextEditingController? controller;
  final String? hint;
  final bool label;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;
  final TextAlign textAlign;
  final int? maxLength;
  final String? Function(String?)? validator;
  final AutovalidateMode? autovalidateMode;
  final void Function(String?)? onSaved;
  final String? initialValue;
  final bool readOnly;
  final double borderRadius;
  final void Function(AddressResult)? onAddressSelected;
  final String apiKey;

  @override
  State<AddressAutocompleteTextField> createState() =>
      _AddressAutocompleteTextFieldState();
}

class _AddressAutocompleteTextFieldState
    extends State<AddressAutocompleteTextField> {
  late TextEditingController _controller;
  late FlutterGooglePlacesSdk _places;
  List<AutocompletePrediction> _predictions = [];
  bool _isAddressSelected = false;
  bool _isSelectingPrediction = false;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    if (widget.initialValue != null) {
      _controller.text = widget.initialValue!;
    }
    _places = FlutterGooglePlacesSdk(widget.apiKey);
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _focusNode
      ..removeListener(_onFocusChanged)
      ..dispose();
    if (widget.controller == null) {
      _controller.dispose();
    }
    _removeOverlay();
    super.dispose();
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      log('[AddressAutocomplete] Focus lost - hiding suggestions');
      _hideSuggestions();
    }
  }

  void _onTextChanged() {
    if (_isSelectingPrediction) return;

    if (mounted) {
      setState(() {
        _isAddressSelected = false;
      });
    }

    final text = _controller.text.trim();
    log('[AddressAutocomplete] Text changed: "$text"');

    if (text.length >= 2) {
      _searchPlaces(text);
    } else {
      log('[AddressAutocomplete] Text too short - hiding suggestions');
      _hideSuggestions();
    }
  }

  Future<void> _searchPlaces(String query) async {
    try {
      log('[AddressAutocomplete] Searching places for: "$query"');
      final predictions = await _places.findAutocompletePredictions(query);

      if (mounted && !_isSelectingPrediction) {
        log(
          '[AddressAutocomplete] Found ${predictions.predictions.length} predictions',
        );
        if (mounted) {
          setState(() {
            _predictions = predictions.predictions;
          });
        }
        _showOverlay();
      }
    } catch (e) {
      log('[AddressAutocomplete] Error fetching predictions: $e');
      _hideSuggestions();
    }
  }

  void _showOverlay() {
    _removeOverlay();
    if (_predictions.isEmpty) {
      log('[AddressAutocomplete] No predictions to show');
      return;
    }

    log('[AddressAutocomplete] Showing suggestions overlay');
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: MediaQuery.of(context).size.width - 32.w,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, 60.h),
          child: Center(
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(widget.borderRadius.r),
              child: Container(
                constraints: BoxConstraints(maxHeight: 200.h),
                decoration: BoxDecoration(
                  color: context.colors.inputBackground,
                  borderRadius: BorderRadius.circular(widget.borderRadius.r),
                  border: Border.all(
                    color: context.colors.inputBorder.withValues(alpha: 0.2),
                  ),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: _predictions.length,
                  itemBuilder: (context, index) {
                    final prediction = _predictions[index];
                    return ListTile(
                      dense: true,
                      leading: Icon(
                        Icons.location_on,
                        color: Colors.blue,
                        size: 20.sp,
                      ),
                      title: Text(
                        prediction.primaryText,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      subtitle: Text(
                        prediction.secondaryText,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[400],
                        ),
                      ),
                      onTap: () => _onPredictionSelected(prediction),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    if (_overlayEntry != null) {
      log('[AddressAutocomplete] Removing suggestions overlay');
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
  }

  void _hideSuggestions() {
    log('[AddressAutocomplete] Hiding suggestions');
    if (mounted) {
      setState(() {
        _predictions = [];
      });
    }
    _removeOverlay();
  }

  Future<void> _onPredictionSelected(AutocompletePrediction prediction) async {
    log('[AddressAutocomplete] Prediction selected: ${prediction.placeId}');

    _isSelectingPrediction = true;
    _hideSuggestions(); // Close immediately after selection

    _controller.text = prediction.fullText;
    FocusScope.of(context).unfocus();

    try {
      final place = await _places.fetchPlace(
        prediction.placeId,
        fields: [PlaceField.Location, PlaceField.Address],
      );

      if (place.place?.latLng != null) {
        log(
          '[AddressAutocomplete] Place details fetched: ${place.place!.address}',
        );
        final result = AddressResult(
          address: place.place!.address ?? prediction.fullText,
          latitude: place.place!.latLng!.lat,
          longitude: place.place!.latLng!.lng,
          placeId: prediction.placeId,
        );
        widget.onAddressSelected?.call(result);
      } else {
        log('[AddressAutocomplete] Place details missing location');
        _fallbackGeocode(prediction);
      }
    } catch (e) {
      log('[AddressAutocomplete] Error fetching place details: $e');
      _fallbackGeocode(prediction);
    } finally {
      _isSelectingPrediction = false;
      if (mounted) {
        setState(() {
          _isAddressSelected = true;
        });
      }
    }
  }

  void _fallbackGeocode(AutocompletePrediction prediction) {
    log('[AddressAutocomplete] Using fallback geocode');
    widget.onAddressSelected?.call(
      AddressResult(
        address: prediction.fullText,
        latitude: 0,
        longitude: 0,
        placeId: prediction.placeId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: TextFormField(
          style: TextStyle(color: Colors.white),
          controller: _controller,
          focusNode: _focusNode,
          enabled: !widget.readOnly,
          cursorColor: Colors.white,
          textCapitalization: widget.textCapitalization,
          textInputAction: widget.textInputAction,
          textAlign: widget.textAlign,
          keyboardType: widget.keyboardType,
          maxLength: widget.maxLength,
          validator: widget.validator,
          onSaved: widget.onSaved,
          autovalidateMode: widget.autovalidateMode,
          decoration: InputDecoration(
            errorMaxLines: 3,
            hintText: !widget.label ? widget.hint : "Enter address",
            labelText: widget.label ? widget.hint : "Enter address",
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.suffixIcon != null
                ? Padding(
                    padding: EdgeInsets.only(right: 16.w),
                    child: widget.suffixIcon,
                  )
                : _controller.text.isNotEmpty && !_isAddressSelected
                ? Padding(
                    padding: EdgeInsets.only(right: 16.w),
                    child: IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: Colors.grey.shade400,
                        size: 20.sp,
                      ),
                      onPressed: () {
                        _controller.clear();
                        _hideSuggestions();
                        if (mounted) {
                          setState(() {
                            _isAddressSelected = false;
                          });
                        }
                      },
                    ),
                  )
                : Icon(Icons.location_on, color: Colors.blue),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 13.h,
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(100.r),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: context.colors.inputBorder.withValues(alpha: 0.10),
              ),
              borderRadius: BorderRadius.circular(100.r),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: context.colors.error),
              borderRadius: BorderRadius.circular(100.r),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: context.colors.error),
              borderRadius: BorderRadius.circular(100.r),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: context.colors.inputBorder.withValues(),
              ),
              borderRadius: BorderRadius.circular(100.r),
            ),
          ),
        ),
      ),
    );
  }
}
