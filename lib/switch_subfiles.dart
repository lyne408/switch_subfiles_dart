import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path_lib;

/*
[lyne408] variable name 确实长了些, 不过好分辨.
严格区分: path, name, directory, file. folderName

name, path 都是 String 的实例.
directory 是 Directory 的实例.
file 是 File 的实例.
*/
class Config {
  final String sourceDirPath;
  final String targetDirPath;

  /// 元素是文件的 basename
  final List<String> subFilenames;
  const Config(this.sourceDirPath, this.targetDirPath, this.subFilenames);

  static Config fromJsonUtf8(List<int> bytes) {
    final jsonString = utf8.decode(bytes);
    final map = json.decode(jsonString) as Map<String, dynamic>;
    // 解决 type '_GrowableList<dynamic>' is not a subtype of type 'List<String>'
    var subFilenamesFromJson = map['subFilenames'];
    List<String> subFilenames = List<String>.from(subFilenamesFromJson);
    return Config(map['sourceDirPath'], map['targetDirPath'], subFilenames);
  }

  List<int> toJsonUtf8() {
    return JsonUtf8Encoder()
        .convert({"sourceDirPath": sourceDirPath, "targetDirPath": targetDirPath, "subFilenames": subFilenames});
  }
}

// CLI 程序不需要这个.
// 以后开发 GUI 程序, 统一管理, 可能需要
// static final  workingDir = '';

/// 默认位于当前要切换的路径的父目录, 是 sibling
const defaultConfigFilename = 'switch_subfiles_config.json';

late final File configFile;

Future<Config> readConfig() async {
  return Config.fromJsonUtf8(await configFile.readAsBytes());
}

Future<void> writeConfig(Config config) async {
  await configFile.writeAsBytes(config.toJsonUtf8());
}

String getMark(String folderName) {
  return '__current = $folderName';
}

/// 在目标文件夹新建一个子文件夹, 其名标识当前切换的. 方便些.
/// 格式: '__current = $newName'
/// 不传 oldName 表示之前没有切换
Future<void> markCurrent(String targetDirPath, String newName, [String? oldName]) async {
  final newMarkDirPath = path_lib.join(targetDirPath, getMark(newName));

  if (null == oldName) {
    await Directory(newMarkDirPath).create();
  } else {
    final oldMarkDirPath = path_lib.join(targetDirPath, getMark(oldName));
    await Directory(oldMarkDirPath).rename(newMarkDirPath);
  }
}

/// 没有传入参数, 表示清空上次切换
/// switchTo() 应接受 configPath 参数. 但目前的需求仅需自动识别 configPath 即可
Future<void> clearSwitch() async {
  // 默认值: 当前工作目录下的
  final configPath = path_lib.join(Directory.current.path, defaultConfigFilename);
  configFile = File(configPath);
  final Config config = await readConfig();
  final subFilenames = config.subFilenames;
  final targetDirPath = config.targetDirPath;
  final sourceDirPath = config.sourceDirPath;
  for (final filename in subFilenames) {
    final oldPath = path_lib.join(targetDirPath, filename);
    final newPath = path_lib.join(sourceDirPath, filename);
    final isDir = await FileSystemEntity.isDirectory(oldPath);
    if (isDir) {
      await Directory(oldPath).rename(newPath);
    } else {
      await File(oldPath).rename(newPath);
    }
  }

  // 删除配置文件
  await configFile.delete();

  final preMark = getMark(path_lib.basename(sourceDirPath));
  // 删除之前的 mark
  await Directory(path_lib.join(targetDirPath, preMark)).delete();
}

/// switchTo() 应接受 sourceDirPath, configPath 两个参数.
/// 目前的需求仅需自动识别 configPath 即可. 所以不需 configFilePath 参数.
Future<void> switchTo(String sourceDirPath) async {
  // 默认值: 当前要切换的路径的 sibling
  final configPath = path_lib.join(path_lib.dirname(sourceDirPath), defaultConfigFilename);
  configFile = File(configPath);

  final String targetDirPath;
  String? preSourceDirPath;
  final List<String> preSubFilenames;
  final subEntities = Directory(sourceDirPath).listSync();
  final List<String> subFilenames = subEntities.map<String>((entity) => path_lib.basename(entity.path)).toList();

  final newSoucreFolderName = path_lib.basename(sourceDirPath);

  /// 若配置文件存在, 表示之前有其它切换
  if (await configFile.exists()) {
    final Config config = await readConfig();
    preSourceDirPath = config.sourceDirPath;
    print('Previous: $preSourceDirPath');
    if (sourceDirPath == preSourceDirPath) {
      print('The same, not need to switch.');
      return;
    } else {
      targetDirPath = config.targetDirPath;
      preSubFilenames = config.subFilenames;

      // 把目标目录下的 subfiles 移动至 **上次切换** 的源目录
      for (final filename in preSubFilenames) {
        final oldPath = path_lib.join(targetDirPath, filename);
        final newPath = path_lib.join(preSourceDirPath, filename);
        if (await FileSystemEntity.isDirectory(oldPath)) {
          await Directory(oldPath).rename(newPath);
        } else {
          await File(oldPath).rename(newPath);
        }
      }
    }
  }
  // 之前没有切换
  else {
    // - `D:\Program_Files\Python\__Python_binaries\python-3.8.10-amd64`
    // - `D:\Program_Files\Python\__Python_binaries\python-3.10.1-amd64`
    // 默认值: 当前要切换的路径的 grandparent
    targetDirPath = path_lib.dirname(path_lib.dirname(sourceDirPath));
  }

  // 把 **现在** 的源目录的 subfiles 移动到 目标目录
  for (var i = 0; i < subEntities.length; i++) {
    final newPath = path_lib.join(targetDirPath, subFilenames[i]);
    await subEntities[i].rename(newPath);
  }

  await writeConfig(Config(sourceDirPath, targetDirPath, subFilenames));

  null == preSourceDirPath
      ? await markCurrent(targetDirPath, newSoucreFolderName)
      : await markCurrent(targetDirPath, newSoucreFolderName, path_lib.basename(preSourceDirPath));
  print('Switch to "$sourceDirPath"');
}
