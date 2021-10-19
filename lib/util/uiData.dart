class UiData {
  String serverPhone(String phone) {
    if (phone.length > 10) return '+82' + phone.substring(1, 11);
    else return phone;
  }
}
