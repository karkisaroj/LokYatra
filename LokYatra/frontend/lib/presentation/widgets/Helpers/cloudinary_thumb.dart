String cloudinaryThumb(String url, {int w = 300, int h = 300}) {
  final idx = url.indexOf('/upload/');
  if (idx == -1) return url;
  final before = url.substring(0, idx + '/upload/'.length);
  final after = url.substring(idx + '/upload/'.length);
  return '$before' 'c_fill,w_$w,h_$h,q_auto,f_auto/$after';
}