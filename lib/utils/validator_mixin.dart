mixin ValidatorMixin {
  // Regular expression for valid email name@domain.com
  final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
  );
  // Regular expression for valid for a string containing atleast 6 characters
  final RegExp _passwordRegExp =
      RegExp(r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-].{5,25}');

  final RegExp _name = RegExp(r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]');

  final RegExp _number = RegExp(r'^\d+$'); // RegExp fto validate numbers
  final RegExp _phoneNumber = RegExp(r'^\d+$'); // RegExp fto validate numbers
  // final RegExp _phoneNumber = RegExp(r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$'); // RegExp fto validate numbers

  String? emailValidator(String email) {
    String e = email.trim();
    if (e.isEmpty) {
      return 'please enter Email';
    } else if (!_emailRegExp.hasMatch(e)) {
      return 'Please Enter a Valid Email Adress';
    }
    return null;
  }

  passwordValidator(String password) {
    // String p = password?.trim();
    if (password.isEmpty) {
      return 'please enter password';
    } else if (!_passwordRegExp.hasMatch(password)) {
      return 'Password must  least 6 characters long';
    }
    return null;
  }

  rePasswordValidator(String password, String pass) {
    if (password != pass) return 'Passwords do not match';
    return null;
  }

  nameValidator(String name, {String? title}) {
    if (name.isEmpty) {
      return 'please enter ${title ?? 'Name'}';
    } else if (!_name.hasMatch(name)) {
      return 'Please enter valid ${title ?? 'Name'}';
    }
    return null;
  }

  groupKeyValidator(String text) {
    if (text.isEmpty) {
      return 'please enter Group Key';
    } else if (!_number.hasMatch(text)) {
      return 'Group key can only include numbers';
    }
    return null;
  }

  phoneNumberValidator(String number) {
    if (number.isEmpty) {
      return 'please enter Phone Number';
    } else if (!_number.hasMatch(number)) {
      return 'Phone number can only include numbers ';
    } else if (!_phoneNumber.hasMatch(number)) {
      return 'Phone number must be between 9 and 12 numbers '; //TODO: edit the RegEx
    }
    // else if (!_phoneNumber.hasMatch(number)) return 'Phone number can only include numbers and cannot be less than 11 characters';
    return null;
  }

  serviceNoValidator(String number) {
    if (number.isEmpty) {
      return 'please enter Service Number';
    } else if (!_number.hasMatch(number)) {
      return 'The Service Number can only include numbers';
    }
    return null;
  }
}
