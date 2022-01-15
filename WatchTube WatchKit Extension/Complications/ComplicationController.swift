//
//  ComplicationController.swift
//  WatchTube WatchKit Extension
//
//  Created by Hugo Mason on 26/12/2021.
//

import WatchKit
import ClockKit

import ClockKit

class ComplicationController: NSObject, CLKComplicationDataSource {
    
    // MARK: - Complication Configuration
    func getComplicationDescriptors(handler: @escaping ([CLKComplicationDescriptor]) -> Void) {
        let descriptors = [
            CLKComplicationDescriptor(identifier: "complication", displayName: "WatchTube", supportedFamilies: [
                CLKComplicationFamily.circularSmall,
                CLKComplicationFamily.extraLarge,
                CLKComplicationFamily.graphicBezel,
                CLKComplicationFamily.graphicCircular,
                CLKComplicationFamily.graphicCorner,
                CLKComplicationFamily.graphicExtraLarge,
                CLKComplicationFamily.graphicRectangular,
                CLKComplicationFamily.modularLarge,
                CLKComplicationFamily.modularSmall,
                CLKComplicationFamily.utilitarianLarge,
                CLKComplicationFamily.utilitarianSmall,
                CLKComplicationFamily.utilitarianSmallFlat
               ]
            )
            // Multiple complication support can be added here with more descriptors
        ]
        
        // Call the handler with the currently supported complication descriptors
        handler(descriptors)
    }
    
    func handleSharedComplicationDescriptors(_ complicationDescriptors: [CLKComplicationDescriptor]) {
        // Do any necessary work to support these newly shared complication descriptors
    }
    
    // MARK: - Timeline Configuration
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        // Call the handler with the last entry date you can currently provide or nil if you can't support future timelines
        handler(nil)
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        // Call the handler with your desired behavior when the device is locked
        handler(.showOnLockScreen)
    }

    // MARK: - Timeline Population
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
            if let template = getComplicationTemplate(for: complication, using: Date()) {
                let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
                handler(entry)
            } else {
                handler(nil)
            }
        }
        
        func getComplicationTemplate(for complication: CLKComplication, using date: Date) -> CLKComplicationTemplate? {
            switch complication.family {
            case .circularSmall:
                return CLKComplicationTemplateCircularSmallSimpleImage(imageProvider: CLKImageProvider(onePieceImage: UIImage(named: "Complication/Circular")!))
            case .extraLarge:
                return CLKComplicationTemplateCircularSmallSimpleImage(imageProvider: CLKImageProvider(onePieceImage: UIImage(named: "Complication/Extra Large")!))
            case .graphicBezel:
                return CLKComplicationTemplateCircularSmallSimpleImage(imageProvider: CLKImageProvider(onePieceImage: UIImage(named: "Complication/Graphic Bezel")!))
            case .graphicCircular:
                return CLKComplicationTemplateGraphicCircularImage(imageProvider: CLKFullColorImageProvider(fullColorImage: UIImage(named: "Complication/Graphic Circular")!))
            case .graphicCorner:
                return CLKComplicationTemplateGraphicCornerCircularImage(imageProvider: CLKFullColorImageProvider(fullColorImage: UIImage(named: "Complication/Graphic Corner")!))
            case .graphicExtraLarge:
                return CLKComplicationTemplateGraphicCircularImage(imageProvider: CLKFullColorImageProvider(fullColorImage: UIImage(named: "Complication/Graphic Extra Large")!))
            case .graphicRectangular:
                return CLKComplicationTemplateGraphicRectangularFullImage(imageProvider: CLKFullColorImageProvider(fullColorImage: UIImage(named: "Complication/Graphic Large Rectangular")!))
            case .modularLarge:
                return CLKComplicationTemplateGraphicCircularImage(imageProvider: CLKFullColorImageProvider(fullColorImage: UIImage(named: "Complication/Modular")!))
            case .modularSmall:
                return CLKComplicationTemplateGraphicCircularImage(imageProvider: CLKFullColorImageProvider(fullColorImage: UIImage(named: "Complication/Modular")!))
            case .utilitarianLarge:
                return CLKComplicationTemplateGraphicCircularImage(imageProvider: CLKFullColorImageProvider(fullColorImage: UIImage(named: "Complication/Utilitarian")!))
            case .utilitarianSmall:
                return CLKComplicationTemplateGraphicCircularImage(imageProvider: CLKFullColorImageProvider(fullColorImage: UIImage(named: "Complication/Utilitarian")!))
            case .utilitarianSmallFlat:
                return CLKComplicationTemplateGraphicCircularImage(imageProvider: CLKFullColorImageProvider(fullColorImage: UIImage(named: "Complication/Utilitarian")!))
            default:
                return nil
            }
        }
    
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries after the given date
        handler(nil)
    }

    // MARK: - Sample Templates
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
            let template = getComplicationTemplate(for: complication, using: Date())
            if let t = template {
                handler(t)
            } else {
                handler(nil)
            }
        }
}
