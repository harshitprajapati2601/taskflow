class Validators {

  Validators._();
  //RegExp(Regular Expression)
  static final _emailRegExp = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? name(String? value){
    //.trim() – Removes whitespace from the beginning and end.
    //?? '' – If the value is null, use an empty string instead.
    final v = value?.trim() ?? '' ;
    if(v.isEmpty) return "Enter Your Name";
    if(v.length<2) return "Name is too short";
    return null;
  }

  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if(v.isEmpty) return "Enter Your Name";
    if(!_emailRegExp.hasMatch(v)) return "Enter a valid email";
    return null;
  }

  static String? password(String? value){
    if(value == null || value.isEmpty)return "Enter Your Password";
    if(value.length<6) return "Use At least 6 characters";
    return null;
  }

  static String? confirmPassword(String? value,String original){
    if(value == null || value.isEmpty) return "Confirm Your password";
    if(value != original) return "Password Don't match";
    return null;
  }
}

