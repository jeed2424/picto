//
//  GifMaker.swift
//  Warbly
//
//  Created by Knox Dobbins on 3/24/21.
//  Copyright © 2021 Warbly. All rights reserved.
//

#if os(iOS)
import UIKit
import MobileCoreServices
#elseif os(OSX)
import AppKit
#endif

import ImageIO
import AVFoundation

public typealias TimePoint = CMTime
public typealias ProgressHandler = (Double) -> Void

/// Errors thrown by Regift
public enum RegiftError: String, Error {
    case DestinationNotFound = "The temp file destination could not be created or found"
    case SourceFormatInvalid = "The source file does not appear to be a valid format"
    case AddFrameToDestination = "An error occurred when adding a frame to the destination"
    case DestinationFinalize = "An error occurred when finalizing the destination"
}

// Convenience struct for managing dispatch groups.
private struct Group {
    let group = DispatchGroup()
    func enter() { group.enter() }
    func leave() { group.leave() }
    func wait() { let _ = group.wait(timeout: DispatchTime.distantFuture) }
}

/// Easily convert a video to a GIF. It can convert the whole thing, or you can choose a section to trim out.
///
/// Synchronous Usage:
///
///      let regift = Regift(sourceFileURL: movieFileURL, frameCount: 24, delayTime: 0.5, loopCount: 7)
///      print(regift.createGif())
///
///      // OR
///
///      let trimmedRegift = Regift(sourceFileURL: movieFileURL, startTime: 30, duration: 15, frameRate: 15)
///      print(trimmedRegift.createGif())
///
/// Asynchronous Usage:
///
///      let regift = Regift.createGIFFromSource(movieFileURL, frameCount: 24, delayTime: 0.5, loopCount: 7) { (result) in
///          print(result)
///      }
///
///      // OR
///
///      let trimmedRegift = Regift.createGIFFromSource(movieFileURL, startTime: 30, duration: 15, frameRate: 15, loopCount: 0) { (result) in
///          print(result)
///      }
///
public struct Regift {

    // Static conversion methods, for convenient and easy-to-use API:
    /**
        Create a GIF from a movie stored at the given URL. This converts the whole video to a GIF meeting the requested output parameters.
        - parameters:
            - sourceFileURL: The source file to create the GIF from.
            - destinationFileURL: An optional destination file to write the GIF to. If you don't include this, a default path will be provided.
            - frameCount: The number of frames to include in the gif; each frame has the same duration and is spaced evenly over the video.
            - delayTime: The amount of time each frame exists for in the GIF.
            - loopCount: The number of times the GIF will repeat. This defaults to `0`, which means that the GIF will repeat infinitely.
            - size: The maximum size of generated GIF. This defaults to `nil`, which specifies the asset’s unscaled dimensions. Setting size will not change the image aspect ratio.
            - completion: A block that will be called when the GIF creation is completed. The `result` parameter provides the path to the file, or will be `nil` if there was an error.
    */
    public static func createGIFFromSource(
        _ sourceFileURL: URL,
        destinationFileURL: URL? = nil,
        frameCount: Int,
        delayTime: Float,
        loopCount: Int = 0,
        size: CGSize? = nil,
        progress: ProgressHandler? = nil,
        completion: (_ result: URL?) -> Void) {
            let gift = Regift(
                sourceFileURL: sourceFileURL,
                destinationFileURL: destinationFileURL,
                frameCount: frameCount,
                delayTime: delayTime,
                loopCount: loopCount,
                size: size,
                progress: progress
            )

            completion(gift.createGif())
    }

    /**
        Create a GIF from a movie stored at the given URL. This allows you to choose a start time and duration in the source material that will be used to create the GIF which meets the output parameters.
        - parameters:
            - sourceFileURL: The source file to create the GIF from.
            - destinationFileURL: An optional destination file to write the GIF to. If you don't include this, a default path will be provided.
            - startTime: The time in seconds in the source material at which you want the GIF to start.
            - duration: The duration in seconds that you want to pull from the source material.
            - frameRate: The desired frame rate of the outputted GIF.
            - loopCount: The number of times the GIF will repeat. This defaults to `0`, which means that the GIF will repeat infinitely.
            - size: The maximum size of generated GIF. This defaults to `nil`, which specifies the asset’s unscaled dimensions. Setting size will not change the image aspect ratio.
            - completion: A block that will be called when the GIF creation is completed. The `result` parameter provides the path to the file, or will be `nil` if there was an error.
    */
    public static func createGIFFromSource(
        _ sourceFileURL: URL,
        destinationFileURL: URL? = nil,
        startTime: Float,
        duration: Float,
        frameRate: Int,
        loopCount: Int = 0,
        size: CGSize? = nil,
        progress: ProgressHandler? = nil,
        completion: (_ result: URL?) -> Void) {
            let gift = Regift(
                sourceFileURL: sourceFileURL,
                destinationFileURL: destinationFileURL,
                startTime: startTime,
                duration: duration,
                frameRate: frameRate,
                loopCount: loopCount,
                size: size,
                progress: progress
            )

            completion(gift.createGif())
    }
    
    public static func createGIF(
        fromAsset asset: AVAsset,
        destinationFileURL: URL? = nil,
        startTime: Float,
        duration: Float,
        frameRate: Int,
        loopCount: Int = 0,
        completion: (_ result: URL?) -> Void) {

        let gift = Regift(
            asset: asset,
            destinationFileURL: destinationFileURL,
            startTime: startTime,
            duration: duration,
            frameRate: frameRate,
            loopCount: loopCount
        )
        
        completion(gift.createGif())
    }

    private struct Constants {
        static let FileName = "regift.gif"
        static let TimeInterval: Int32 = 600
        static let Tolerance = 0.01
    }

    /// A reference to the asset we are converting.
    private var asset: AVAsset

    /// The url for the source file.
    private var sourceFileURL: URL?

    /// The point in time in the source which we will start from.
    private var startTime: Float = 0

    /// The desired duration of the gif.
    private var duration: Float

    /// The total length of the movie, in seconds.
    private var movieLength: Float

    /// The number of frames we are going to use to create the gif.
    private let frameCount: Int

    /// The amount of time each frame will remain on screen in the gif.
    private let delayTime: Float

    /// The number of times the gif will loop (0 is infinite).
    private let loopCount: Int

    /// The destination path for the generated file.
    private var destinationFileURL: URL?

    /// The handler to inform you about the current GIF export progress
    private var progress: ProgressHandler?
    
    /// The maximum width/height for the generated file.
    fileprivate let size: CGSize?
    
    /**
        Create a GIF from a movie stored at the given URL. This converts the whole video to a GIF meeting the requested output parameters.
        - parameters:
            - sourceFileURL: The source file to create the GIF from.
            - destinationFileURL: An optional destination file to write the GIF to. If you don't include this, a default path will be provided.
            - frameCount: The number of frames to include in the gif; each frame has the same duration and is spaced evenly over the video.
            - delayTime: The amount of time each frame exists for in the GIF.
            - loopCount: The number of times the GIF will repeat. This defaults to `0`, which means that the GIF will repeat infinitely.
            - size: The maximum size of generated GIF. This defaults to `nil`, which specifies the asset’s unscaled dimensions. Setting size will not change the image aspect ratio.
     */
    public init(sourceFileURL: URL, destinationFileURL: URL? = nil, frameCount: Int, delayTime: Float, loopCount: Int = 0, size: CGSize? = nil, progress: ProgressHandler? = nil) {
        self.sourceFileURL = sourceFileURL
        self.asset = AVURLAsset(url: sourceFileURL, options: nil)
        self.movieLength = Float(asset.duration.value) / Float(asset.duration.timescale)
        self.duration = movieLength
        self.delayTime = delayTime
        self.loopCount = loopCount
        self.destinationFileURL = destinationFileURL
        self.frameCount = frameCount
        self.size = size
        self.progress = progress
    }

    /**
        Create a GIF from a movie stored at the given URL. This allows you to choose a start time and duration in the source material that will be used to create the GIF which meets the output parameters.
        - parameters:
            - sourceFileURL: The source file to create the GIF from.
            - destinationFileURL: An optional destination file to write the GIF to. If you don't include this, a default path will be provided.
            - startTime: The time in seconds in the source material at which you want the GIF to start.
            - duration: The duration in seconds that you want to pull from the source material.
            - frameRate: The desired frame rate of the outputted GIF.
            - loopCount: The number of times the GIF will repeat. This defaults to `0`, which means that the GIF will repeat infinitely.
            - size: The maximum size of generated GIF. This defaults to `nil`, which specifies the asset’s unscaled dimensions. Setting size will not change the image aspect ratio.
     */
    public init(sourceFileURL: URL, destinationFileURL: URL? = nil, startTime: Float, duration: Float, frameRate: Int, loopCount: Int = 0, size: CGSize? = nil, progress: ProgressHandler? = nil) {
        self.sourceFileURL = sourceFileURL
        self.asset = AVURLAsset(url: sourceFileURL, options: nil)
        self.destinationFileURL = destinationFileURL
        self.startTime = startTime
        self.duration = duration

        // The delay time is based on the desired framerate of the gif.
        self.delayTime = (1.0 / Float(frameRate))

        // The frame count is based on the desired length and framerate of the gif.
        self.frameCount = Int(duration * Float(frameRate))

        // The total length of the file, in seconds.
        self.movieLength = Float(asset.duration.value) / Float(asset.duration.timescale)

        self.loopCount = loopCount
        self.size = size
        self.progress = progress
    }
    
    public init(asset: AVAsset, destinationFileURL: URL? = nil, startTime: Float, duration: Float, frameRate: Int, loopCount: Int = 0, size: CGSize? = nil, progress: ProgressHandler? = nil) {
        self.asset = asset
        self.destinationFileURL = destinationFileURL
        self.startTime = startTime
        self.duration = duration
        self.delayTime = (1.0 / Float(frameRate))
        self.frameCount = Int(duration * Float(frameRate))
        self.movieLength = Float(asset.duration.value) / Float(asset.duration.timescale)
        self.loopCount = loopCount
        self.size = size
        self.progress = progress
    }

    /**
        Get the URL of the GIF created with the attributes provided in the initializer.
        - returns: The path to the created GIF, or `nil` if there was an error creating it.
    */
    public func createGif() -> URL? {

        let fileProperties = [kCGImagePropertyGIFDictionary as String:[
            kCGImagePropertyGIFLoopCount as String: NSNumber(value: Int32(loopCount) as Int32)],
            kCGImagePropertyGIFHasGlobalColorMap as String: NSValue(nonretainedObject: true)
        ] as [String : Any]
        
        let frameProperties = [
            kCGImagePropertyGIFDictionary as String:[
                kCGImagePropertyGIFDelayTime as String:delayTime
            ]
        ]

        // How far along the video track we want to move, in seconds.
        let increment = Float(duration) / Float(frameCount)
        
        // Add each of the frames to the buffer
        var timePoints: [TimePoint] = []
        
        for frameNumber in 0 ..< frameCount {
            let seconds: Float64 = Float64(startTime) + (Float64(increment) * Float64(frameNumber))
            let time = CMTimeMakeWithSeconds(seconds, preferredTimescale: Constants.TimeInterval)
            
            timePoints.append(time)
        }
        
        do {
            return try createGIFForTimePoints(timePoints, fileProperties: fileProperties as [String : AnyObject], frameProperties: frameProperties as [String : AnyObject], frameCount: frameCount, size: size)
            
        } catch {
            return nil
        }
    }

    /**
        Create a GIF using the given time points in a movie file stored in this Regift's `asset`.
    
        - parameters:
            - timePoints: timePoints An array of `TimePoint`s (which are typealiased `CMTime`s) to use as the frames in the GIF.
            - fileProperties: The desired attributes of the resulting GIF.
            - frameProperties: The desired attributes of each frame in the resulting GIF.
            - frameCount: The desired number of frames for the GIF. *NOTE: This seems redundant to me, as `timePoints.count` should really be what we are after, but I'm hesitant to change the API here.*
            - size: The maximum size of generated GIF. This defaults to `nil`, which specifies the asset’s unscaled dimensions. Setting size will not change the image aspect ratio.
        - returns: The path to the created GIF, or `nil` if there was an error creating it.
    */
    public func createGIFForTimePoints(_ timePoints: [TimePoint], fileProperties: [String: AnyObject], frameProperties: [String: AnyObject], frameCount: Int, size: CGSize? = nil) throws -> URL {
        // Ensure the source media is a valid file.
        guard !asset.tracks(withMediaCharacteristic: .visual).isEmpty else {
            throw RegiftError.SourceFormatInvalid
        }

        var fileURL:URL?
        if self.destinationFileURL != nil {
            fileURL = self.destinationFileURL
        } else {
            let temporaryFile = (NSTemporaryDirectory() as NSString).appendingPathComponent(Constants.FileName)
            fileURL = URL(fileURLWithPath: temporaryFile)
        }
        
        guard let destination = CGImageDestinationCreateWithURL(fileURL! as CFURL, kUTTypeGIF, frameCount, nil) else {
            throw RegiftError.DestinationNotFound
        }
        
        CGImageDestinationSetProperties(destination, fileProperties as CFDictionary)
        
        let generator = AVAssetImageGenerator(asset: asset)
        
        generator.appliesPreferredTrackTransform = true
        if let size = size {
            generator.maximumSize = size
        }
        
        let tolerance = CMTimeMakeWithSeconds(Constants.Tolerance, preferredTimescale: Constants.TimeInterval)
        generator.requestedTimeToleranceBefore = tolerance
        generator.requestedTimeToleranceAfter = tolerance

        // Transform timePoints to times for the async asset generator method.
        var times = [NSValue]()
        for time in timePoints {
            times.append(NSValue(time: time))
        }

        // Create a dispatch group to force synchronous behavior on an asynchronous method.
        let gifGroup = Group()
        gifGroup.enter()

        var handledTimes: Double = 0
        generator.generateCGImagesAsynchronously(forTimes: times, completionHandler: { (requestedTime, image, actualTime, result, error) in
            handledTimes += 1
            guard let imageRef = image , error == nil else {
                print("An error occurred: \(String(describing: error)), image is \(String(describing: image))")
                if requestedTime == times.last?.timeValue {
                    gifGroup.leave()
                }
                return
            }

            CGImageDestinationAddImage(destination, imageRef, frameProperties as CFDictionary)
            self.progress?(min(1.0, handledTimes/max(1.0, Double(times.count))))
            if requestedTime == times.last?.timeValue {
                gifGroup.leave()
            }
        })

        // Wait for the asynchronous generator to finish.
        gifGroup.wait()
        
        CGImageDestinationSetProperties(destination, fileProperties as CFDictionary)
        
        // Finalize the gif
        if !CGImageDestinationFinalize(destination) {
            throw RegiftError.DestinationFinalize
        }
        
        return fileURL!
    }
}


import AVFoundation

public extension AVAssetImageGenerator {
    func generateCGImagesAsynchronouslyForTimePoints(timePoints: [TimePoint], completionHandler: @escaping AVAssetImageGeneratorCompletionHandler) {
        let times = timePoints.map {timePoint in
            return NSValue(time: timePoint)
        }
        self.generateCGImagesAsynchronously(forTimes: times, completionHandler: completionHandler)
    }
}


import UIKit
import ImageIO
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}



extension UIImage {
    
    public class func gifImageWithData(_ data: Data) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            print("image doesn't exist")
            return nil
        }
        
        return UIImage.animatedImageWithSource(source)
    }
    
    public class func gifImageWithURL(_ gifUrl:String) -> UIImage? {
        guard let bundleURL:URL? = URL(string: gifUrl)
            else {
                print("image named \"\(gifUrl)\" doesn't exist")
                return nil
        }
        guard let imageData = try? Data(contentsOf: bundleURL!) else {
            print("image named \"\(gifUrl)\" into NSData")
            return nil
        }
        
        return gifImageWithData(imageData)
    }
    
    public class func gifImageWithName(_ name: String) -> UIImage? {
        guard let bundleURL = Bundle.main
            .url(forResource: name, withExtension: "gif") else {
                print("SwiftGif: This image named \"\(name)\" does not exist")
                return nil
        }
        guard let imageData = try? Data(contentsOf: bundleURL) else {
            print("SwiftGif: Cannot turn image named \"\(name)\" into NSData")
            return nil
        }
        
        return gifImageWithData(imageData)
    }
    
    class func delayForImageAtIndex(_ index: Int, source: CGImageSource!) -> Double {
        var delay = 0.1
        
        let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
        let gifProperties: CFDictionary = unsafeBitCast(
            CFDictionaryGetValue(cfProperties,
                Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque()),
            to: CFDictionary.self)
        
        var delayObject: AnyObject = unsafeBitCast(
            CFDictionaryGetValue(gifProperties,
                Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()),
            to: AnyObject.self)
        if delayObject.doubleValue == 0 {
            delayObject = unsafeBitCast(CFDictionaryGetValue(gifProperties,
                Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()), to: AnyObject.self)
        }
        
        delay = delayObject as! Double
        
        if delay < 0.1 {
            delay = 0.1
        }
        
        return delay
    }
    
    class func gcdForPair(_ a: Int?, _ b: Int?) -> Int {
        var a = a
        var b = b
        if b == nil || a == nil {
            if b != nil {
                return b!
            } else if a != nil {
                return a!
            } else {
                return 0
            }
        }
        
        if a < b {
            let c = a
            a = b
            b = c
        }
        
        var rest: Int
        while true {
            rest = a! % b!
            
            if rest == 0 {
                return b!
            } else {
                a = b
                b = rest
            }
        }
    }
    
    class func gcdForArray(_ array: Array<Int>) -> Int {
        if array.isEmpty {
            return 1
        }
        
        var gcd = array[0]
        
        for val in array {
            gcd = UIImage.gcdForPair(val, gcd)
        }
        
        return gcd
    }
    
    class func animatedImageWithSource(_ source: CGImageSource) -> UIImage? {
        let count = CGImageSourceGetCount(source)
        var images = [CGImage]()
        var delays = [Int]()
        
        for i in 0..<count {
            if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
                images.append(image)
            }
            
            let delaySeconds = UIImage.delayForImageAtIndex(Int(i),
                source: source)
            delays.append(Int(delaySeconds * 1000.0)) // Seconds to ms
        }
        
        let duration: Int = {
            var sum = 0
            
            for val: Int in delays {
                sum += val
            }
            
            return sum
        }()
        
        let gcd = gcdForArray(delays)
        var frames = [UIImage]()
        
        var frame: UIImage
        var frameCount: Int
        for i in 0..<count {
            frame = UIImage(cgImage: images[Int(i)])
            frameCount = Int(delays[Int(i)] / gcd)
            
            for _ in 0..<frameCount {
                frames.append(frame)
            }
        }
        
        let animation = UIImage.animatedImage(with: frames,
            duration: Double(duration) / 1000.0)
        
        return animation
    }
}
