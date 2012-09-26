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
#import "Settings.h"
#import "utilities.h"
#import "Stroke.h"

@implementation Track (Import)

-(Track*)initWithCoder:(NSCoder*)dec {
//    NSLog(@"Track initWithCoder");
    self = (Track*)[NSEntityDescription insertNewObjectForEntityForName:@"Track" inManagedObjectContext:Settings.sharedInstance.moc];
    if (self) {
        self.date = [dec decodeObjectForKey:@"date"];
        self.distance = [dec decodeObjectForKey:@"distance"];
        self.locality = [dec decodeObjectForKey:@"locality"];
        self.motion = [dec decodeObjectForKey:@"motion"];
        self.name = [dec decodeObjectForKey:@"name"];
        self.period = [dec decodeObjectForKey:@"period"];
        self.strokes = [dec decodeObjectForKey:@"strokes"];
        self.track = [dec decodeObjectForKey:@"track"];
        self.waterway = [dec decodeObjectForKey:@"waterway"];
    }
    return self;
}

// not encoding other Core Data objecs: boat, rowers, coxswain, course
-(void)encodeWithCoder:(NSCoder *)enc {
    [enc encodeObject:self.date forKey:@"date"];
    [enc encodeObject:self.distance forKey:@"distance"];
    [enc encodeObject:self.locality forKey:@"locality"];
    [enc encodeObject:self.motion forKey:@"motion"];
    [enc encodeObject:self.name forKey:@"name"];
    [enc encodeObject:self.period forKey:@"period"];
    [enc encodeObject:self.strokes forKey:@"strokes"];
    [enc encodeObject:self.track forKey:@"track"];
    [enc encodeObject:self.waterway forKey:@"waterway"];
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
            [x writeFullElement:@"description" data:defaultName(self.locality, @"")];
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
                [x writeStartElement:@"description"]; {
                    NSString * cdata = [NSString stringWithFormat:@"<p>Distance: %@<br>Time: %@</p><p>Average speed: %@<br>Average stroke frequency: %3.1f s/m<br>Boat: %@</p>",dispLength(trackData.totalDistance),hms(trackData.rowingTime),dispSpeed(trackData.averageRowingSpeed,Settings.sharedInstance.speedUnit,NO), 60*self.strokes.intValue/trackData.totalTime, defaultName(self.boat.name, @"unkown")];
                    [x writeCData:cdata];
                } // description
                [x writeEndElement];
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
            for (MKPointAnnotation * p in trackData.pins) {
                [x writeStartElement:@"Placemark"]; {
                    [x writeFullElement:@"name" data:p.title];
                    [x writeStartElement:@"Point"]; {
                        [x writeFullElement:@"coordinates" data:[NSString stringWithFormat:@"%8.6f,%8.6f",p.coordinate.longitude,p.coordinate.latitude]];
                    } //Point
                    [x writeEndElement];
                } //Placemark
                [x writeEndElement];
            }
        } //Document
        [x writeEndElement];
    } // kml
    [x writeEndElement];
    [x writeEndDocument];
    NSError * error;
    BOOL OK = [[x toString] writeToURL:file atomically:NO encoding:NSUTF8StringEncoding error:&error];
    if (!OK) {
        NSLog(@"%@", [error localizedDescription]);
    }
    return OK;
}




@end
