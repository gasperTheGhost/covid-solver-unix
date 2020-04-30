import 'dart:io';

void main(List<String> arguments) async {
  var outputdir = '';
  if(arguments.length==3){
    outputdir = arguments[2] + '/';
  } else if(arguments.length==2) {
    outputdir = '';
  } else {
    print('Invalid arguments! Cannot split molecule package!');
    exit(0);
  }
  splitPackage(arguments[0], arguments[1], outputdir);
}

void writeToOutput(String blockToWrite, String fileName){
  var outputFile = File(fileName);
  outputFile.createSync(recursive: true);
  outputFile.writeAsStringSync(blockToWrite, mode: FileMode.append);
}

void splitPackage(package, threads, outputdir){
  var separator = '''
\$\$\$\$''';
  var current = 1;
  var contents = File('3D_structures_'+package.toString()+'.sdf').readAsStringSync() ;
  var contentArray = contents.split('\$\$\$\$');
  contentArray.removeLast();

  var div = contentArray.length ~/ int.tryParse(threads);
  var rem = contentArray.length % int.tryParse(threads);
  var tempLen = [];
  var i = 1;
  while(i <= int.parse(threads)){
    if(i <= rem){
      tempLen.add(div+1);
    } else {
      tempLen.add(div);
    }
    i = i + 1;
  }

  for(var itm in tempLen){
    var n = 0;
    while(n < itm){
      writeToOutput(contentArray[n]+separator, outputdir+'temp'+current.toString()+'.sdf');
      n = n + 1;
    }
    current = current+1;
  }
}