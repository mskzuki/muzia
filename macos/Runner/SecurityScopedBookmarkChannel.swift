import Cocoa
import FlutterMacOS

final class SecurityScopedBookmarkChannel {
  private static let name = "muzia/security_scoped_bookmarks"
  private static var activeURLs: [String: URL] = [:]

  static func register(on viewController: FlutterViewController) {
    let channel = FlutterMethodChannel(
      name: name,
      binaryMessenger: viewController.engine.binaryMessenger
    )
    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "createBookmark":
        createBookmark(call: call, result: result)
      case "restoreBookmark":
        restoreBookmark(call: call, result: result)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private static func createBookmark(
    call: FlutterMethodCall,
    result: @escaping FlutterResult
  ) {
    guard
      let arguments = call.arguments as? [String: Any],
      let path = arguments["path"] as? String
    else {
      result(FlutterError(code: "invalid_arguments", message: "path is required", details: nil))
      return
    }

    do {
      let url = URL(fileURLWithPath: path)
      let data = try url.bookmarkData(
        options: [.withSecurityScope, .securityScopeAllowOnlyReadAccess],
        includingResourceValuesForKeys: nil,
        relativeTo: nil
      )
      result(FlutterStandardTypedData(bytes: data))
    } catch {
      result(FlutterError(code: "bookmark_creation_failed", message: error.localizedDescription, details: nil))
    }
  }

  private static func restoreBookmark(
    call: FlutterMethodCall,
    result: @escaping FlutterResult
  ) {
    guard
      let arguments = call.arguments as? [String: Any],
      let typedData = arguments["bookmark"] as? FlutterStandardTypedData
    else {
      result(FlutterError(code: "invalid_arguments", message: "bookmark is required", details: nil))
      return
    }

    do {
      var isStale = false
      let url = try URL(
        resolvingBookmarkData: typedData.data,
        options: [.withSecurityScope],
        relativeTo: nil,
        bookmarkDataIsStale: &isStale
      )
      guard url.startAccessingSecurityScopedResource() else {
        result(FlutterError(code: "bookmark_access_denied", message: "フォルダへのアクセス権を復元できませんでした。", details: nil))
        return
      }
      activeURLs[url.path] = url

      var refreshedBookmark = typedData.data
      if isStale {
        refreshedBookmark = try url.bookmarkData(
          options: [.withSecurityScope, .securityScopeAllowOnlyReadAccess],
          includingResourceValuesForKeys: nil,
          relativeTo: nil
        )
      }
      result([
        "path": url.path,
        "bookmark": FlutterStandardTypedData(bytes: refreshedBookmark),
      ])
    } catch {
      result(FlutterError(code: "bookmark_resolution_failed", message: error.localizedDescription, details: nil))
    }
  }
}
