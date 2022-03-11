import 'package:switch_subfiles/switch_subfiles.dart' as switch_subfiles;

void main(List<String> args) async {
  if (args.isEmpty) {
    await switch_subfiles.clearSwitch();
  } else {
    switch_subfiles.switchTo(args[0]);
  }
}
