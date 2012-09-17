//
//  Track+Import.m
//  iRow
//
//  Created by David van Leeuwen on 9/7/12.
//  Copyright (c) 2012 strApps. All rights reserved.
//

#import "Track+Import.h"
#import "XMLWriter.h"
#import "TrackData.h"
#import "RelativeDate.h"

@implementation Track (Import)

-(void)importFrom:(TrackExport *)orig {
    self.date = orig.date;
    self.distance = orig.distance;
    self.locality = orig.locality;
    self.motion = orig.motion;
    self.name = orig.name;
    self.period = orig.period;
    self.strokes = orig.strokes;
    self.track = orig.track;
    self.waterway = orig.waterway;
}

// This is really an export function, I wil have to rename the class...
-(BOOL)writeKML:(NSURL *)file {
    XMLWriter * x = [[XMLWriter alloc] init];
    TrackData * trackData = (TrackData*)[NSKeyedUnarchiver unarchiveObjectWithData:self.track];
    [x writeStartDocumentWithEncodingAndVersion:@"UTF-8" version:@"1.0"];
    [x writeStartElement:@"kml"]; {
        [x writeAttribute:@"xmlns" value:@"http://www.opengis.net/kml/2.2"];
        [x writeStartElement:@"Document"]; {
            [x writeFullElement:@"name" data:self.name]; 
            [x writeFullElement:@"description" data:self.locality]; 
            [x writeStartElement:@"Style"]; {
                [x writeAttribute:@"id" value:@"trackStyle"]; 
                [x writeStartElement:@"LineStyle"];
                   [x writeFullElement:@"color" data:@"ff800080"];
                   [x writeFullElement:@"width" data:@"6"];
                [x writeEndElement];
            }
            [x writeEndElement]; // Style
            [x writeStartElement:@"Placemark"]; {
                NSDate * date = self.date!=nil ? self.date : trackData.startLocation.timestamp;
                if (date==nil) date = [NSDate date];
                [x writeFullElement:@"name" data:[date mediumshortDateTime]];
                if (self.waterway) [x writeFullElement:@"description" data:self.waterway];
                [x writeFullElement:@"styleUrl" data:@"#trackStyle"];
                [x writeStartElement:@"LineString"]; {
                    [x writeFullElement:@"extrude" data:@"0"];
                    [x writeFullElement:@"tessellate" data:@"1"];
                    [x writeStartElement:@"coordinates"]; {
                        for (CLLocation * loc in trackData.locations) {
                            [[x writeLinebreak] writeIndentation];
                            [x writeCharacters:[NSString stringWithFormat:@"%8.6f,%8.6f,0", loc.coordinate.longitude, loc.coordinate.latitude]];
                            [[x writeLinebreak] writeIndentation];
                        }
                    } //coordinates
                    [x writeEndElement];
                } //LineString
                [x writeEndElement];
            } // Placemark
            [x writeEndElement];
        } //Document
        [x writeEndElement];
    } // kml
    [x writeEndElement];
    [x writeEndDocument];
    NSError * error;
    BOOL OK = [[x toString] writeToURL:file atomically:NO encoding:NSStringEncodingConversionAllowLossy error:&error];
    if (!OK) {
        NSLog(@"%@", [error localizedDescription]);
    }
    return OK;
}



@end
