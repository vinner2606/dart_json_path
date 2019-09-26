class JsonPathUtility {
  int getPositionOfArray(String str) {
    RegExp exp = new RegExp("\[[0-9]*\]");
    if (exp.hasMatch(str)) {
      Match match = exp.firstMatch(str);
      return int.tryParse(str.substring(match.start+1, match.end-1));
    }
    return -1;
  }

  bool itIsStarOrEmpty(String str) {
    RegExp exp = new RegExp("[* ]");
    if (exp.hasMatch(str)) {
      return true;
    }
    return false;
  }
}
