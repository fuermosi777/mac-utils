// 取消所有显示器镜像。Hammerspoon 重载后会丢失被镜像屏幕的引用（它不在 allScreens() 里），
// 所以直接用 CoreGraphics 遍历在线显示器来取消。
import CoreGraphics

var count: UInt32 = 0
CGGetOnlineDisplayList(0, nil, &count)
var ids = [CGDirectDisplayID](repeating: 0, count: Int(count))
CGGetOnlineDisplayList(count, &ids, &count)

let mirrored = ids.filter { CGDisplayMirrorsDisplay($0) != kCGNullDirectDisplay }
if mirrored.isEmpty { print("no mirrored displays"); exit(0) }

var config: CGDisplayConfigRef?
guard CGBeginDisplayConfiguration(&config) == .success else { print("begin failed"); exit(1) }
for id in mirrored { CGConfigureDisplayMirrorOfDisplay(config, id, kCGNullDirectDisplay) }
let err = CGCompleteDisplayConfiguration(config, .permanently)
print("unmirrored \(mirrored.count) display(s): \(err == .success ? "ok" : "error \(err.rawValue)")")
exit(err == .success ? 0 : 1)
