
import Glibc
import Sua

if !Stdin.isTerminal {

  var stream = CodeUnitStream()
  var bytesCount = 0
  var newLineCount = 0
  var wordCount = 0

  try Stdin.readByteLines() { line in
    let len = line.count
    bytesCount += len
    if len > 0 && line[len - 1] == 10 {
      newLineCount += 1
    }
    //p(line)
    //p(String.fromCharCodes(line))
    stream.codeUnits = line
    while !stream.isEol {
      // 32 - space; 10 - new line; 9 - tab; 13 - carriage return
      // 160 - unicode space: \u00a0
      stream.eatWhile { (c: UInt8) in
        return c == 32 || c == 10 || c == 9 || c == 13 || c == 160
      }
      if stream.eatWhileNeitherFive(32, c2: 10, c3: 9, c4: 13, c5: 160) {
        wordCount += 1
      }
    }
  }

  print("  \(newLineCount)   \(wordCount)   \(bytesCount)")
} else {
  print("Usage: call it by passing a pipe or standard input.\n" +
    "E.g. WordCounter < some_sample.txt\n" +
    "     ls -l | WordCounter")
}
