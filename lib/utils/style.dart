import 'package:flutter/material.dart';
import '../colors/colors.dart';

class Styles{
  static const boxme = BoxDecoration(
      color:ColorConstant.deepblue,
      borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight:Radius.circular(20),
          bottomLeft: Radius.circular(20) )
  );
  static const boxsomebody = BoxDecoration(
      color:  ColorConstant.chatrece,
      borderRadius: BorderRadius.only(topRight:Radius.circular(20),
          bottomLeft: Radius.circular(20),bottomRight: Radius.circular(20) )
  );
  static const imageboxme = BoxDecoration(
      color:ColorConstant.deepblue,
      borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight:Radius.circular(20),
          )
  );
  static const imageboxsomebody = BoxDecoration(
      color:  ColorConstant.chatrece,
      borderRadius: BorderRadius.only(topRight:Radius.circular(20),
          )
  );
}