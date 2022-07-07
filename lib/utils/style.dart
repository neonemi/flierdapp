import 'package:flutter/material.dart';
import '../colors/colors.dart';

class Styles{
  static const boxme = BoxDecoration(
      color:ColorConstant.deepblue,
      borderRadius: BorderRadius.only(topLeft: Radius.circular(10),topRight:Radius.circular(10),bottomLeft: Radius.circular(10) )
  );
  static const boxsomebody = BoxDecoration(
      color:  ColorConstant.chatrece,
      borderRadius: BorderRadius.only(topRight:Radius.circular(10),
          bottomLeft: Radius.circular(10),bottomRight: Radius.circular(10) )
  );
}