
import CSua
import Glibc


public enum SysError: ErrorType {
  case InvalidOpenFileOperation(operation: String)
}

public enum FileOperation: Int {
  case R
  case W
  case A
  case Read
  case Write
  case Append
}

public enum PopenOperation: String {
  case R
  case W
  case RE
  case WE
  case Read
  case Write
  case ReadWithCloexec
  case WriteWithCloexec
}

// This alias allows other files like the FileBrowser to declare this type
// without having to import Glibc as well.
public typealias DirentEntry = UnsafeMutablePointer<dirent>

public class PosixSys {

  public static let DEFAULT_DIR_MODE = S_IRWXU | S_IRWXG | S_IRWXO

  public static let DEFAULT_FILE_MODE = S_IRUSR | S_IWUSR | S_IRGRP | S_IWGRP |
      S_IROTH

  public static let SEEK_SET: Int32 = 0
  public static let SEEK_CUR: Int32 = 1
  public static let SEEK_END: Int32 = 2

  public static let STDIN_FD: Int32 = 0
  public static let STDOUT_FD: Int32 = 1
  public static let STDERR_FD: Int32 = 2

  public func open(path: String, flags: Int32, mode: UInt32) -> Int32 {
    return retry { csua_open(path, flags, mode) }
  }

  public func openFile(filePath: String, operation: FileOperation = .R,
      mode: UInt32 = DEFAULT_FILE_MODE) -> Int32 {
    var flags: Int32 = 0
    switch operation {
      case .R, .Read: flags = O_RDONLY
      case .W, .Write: flags = O_RDWR | O_CREAT | O_TRUNC
      case .A, .Append: flags = O_RDWR | O_CREAT | O_APPEND
    }
    flags |= O_CLOEXEC
    return open(filePath, flags: flags, mode: mode)
  }

  public func doOpenDir(dirPath: String) -> Int32 {
    return open(dirPath, flags: O_RDONLY | O_DIRECTORY, mode: 0)
  }

  public func mkdir(dirPath: String, mode: UInt32 = DEFAULT_DIR_MODE) -> Int32 {
    return retry { Glibc.mkdir(dirPath, mode) }
  }

  public func read(fd: Int32, address: UnsafeMutablePointer<Void>,
      length: Int) -> Int {
    return retry { Glibc.read(fd, address, length) }
  }

  public func write(fd: Int32, address: UnsafePointer<Void>,
      length: Int) -> Int {
    return retry { Glibc.write(fd, address, length) }
  }

  public func writeString(fd: Int32, string: String) -> Int {
    var a = Array(string.utf8)
    return write(fd, address: &a, length: a.count)
  }

  public func close(fd: Int32) -> Int32 {
    return retry { Glibc.close(fd) }
  }

  public func fflush(stream: UnsafeMutablePointer<FILE> = nil) -> Int32 {
    return Glibc.fflush(stream)
  }

  public func lseek(fd: Int32, offset: Int, whence: Int32) -> Int {
    return retry { Glibc.lseek(fd, offset, whence) }
  }

  public var pid: Int32 {
    return Glibc.getpid()
  }

  public func rename(oldPath: String, newPath: String) -> Int32 {
    return Glibc.rename(oldPath, newPath)
  }

  public func unlink(path: String) -> Int32 {
    return Glibc.unlink(path)
  }

  public var cwd: String? {
    var a = [CChar](count:256, repeatedValue: 0)
    let i = Glibc.getcwd(&a, 255)
    if i != nil {
      return String.fromCharCodes(a)
    }
    return nil
  }

  // Named with a do prefix to avoid conflict with functions and types of
  // name stat.
  public func doStat(path: String, buffer: UnsafeMutablePointer<stat>)
      -> Int32 {
    return Glibc.stat(path, buffer)
  }

  public func lstat(path: String, buffer: UnsafeMutablePointer<stat>) -> Int32 {
    return Glibc.lstat(path, buffer)
  }

  public func statBuffer() -> stat {
    return stat()
  }

  public func readdir(dirp: COpaquePointer) -> DirentEntry {
    return dirp != nil ? Glibc.readdir(dirp) : nil
  }

  public func opendir(path: String) -> COpaquePointer {
    return Glibc.opendir(path)
  }

  public func opendir(pathBytes: [UInt8]) -> COpaquePointer {
    return Glibc.opendir(UnsafePointer<CChar>(pathBytes))
  }

  public func closedir(dirp: COpaquePointer) -> Int32 {
    return retry { Glibc.closedir(dirp) }
  }

  public func fgets(buffer: UnsafeMutablePointer<CChar>, length: Int32,
      fp: UnsafeMutablePointer<FILE>) -> UnsafeMutablePointer<CChar> {
    return Glibc.fgets(buffer, length, fp)
  }

  public func fread(buffer: UnsafeMutablePointer<Void>, size: Int,
      nmemb: Int, fp: UnsafeMutablePointer<FILE>) -> Int {
    return Glibc.fread(buffer, size, nmemb, fp)
  }

  public func popen(command: String, operation: PopenOperation = .R)
      -> UnsafeMutablePointer<FILE> {
    var op = "r"
    switch operation {
      case .R, .Read: op = "r"
      case .W, .Write: op = "w"
      case .RE, .ReadWithCloexec: op = "re"
      case .WE, .WriteWithCloexec: op = "we"
    }
    return Glibc.popen(command, op)
  }

  public func pclose(fp: UnsafeMutablePointer<FILE>) -> Int32 {
    return Glibc.pclose(fp)
  }

  public func getenv(key: String) -> String? {
    let vp = Glibc.getenv(key)
    return vp != nil ? String.fromCString(vp) : nil
  }

  public func isatty(fd: Int32) -> Bool {
    return Glibc.isatty(fd) == 1
  }

  public func strlen(sp: UnsafePointer<CChar>) -> UInt {
    return Glibc.strlen(sp)
  }

  public func sleep(n: UInt32) {
    Glibc.sleep(n)
  }

  // The environ variable is made available by the CSua sister project
  // dependency.
  public var environment: [String: String] {
    var env = [String: String]()
    var i = 0
    while true {
      let nm = (environ + i).memory
      if nm == nil {
        break
      }
      let np = UnsafePointer<CChar>(nm)
      if let s = String.fromCString(np) {
        let (key, value) = s.splitOnce("=")
        env[key!] = value ?? ""
      }
      i += 1
    }
    return env
  }

  public func retry(fn: () -> Int32) -> Int32 {
    var value = fn()
    while value == -1 {
      if errno != EINTR { break }
      value = fn()
    }
    return value
  }

  public func retry(fn: () -> Int) -> Int {
    var value = fn()
    while value == -1 {
      if errno != EINTR { break }
      value = fn()
    }
    return value
  }

}

public let Sys = PosixSys()
