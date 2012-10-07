//
//  Course+Import.m
//  iRow
//
//  Created by David van Leeuwen on 9/26/12.
//  Copyright (c) 2012 strApps. All rights reserved.
//

#import "Course+Import.h"
#import "Settings.h"
#import "CourseData.h"
#import "XMLWriter.h"
#import "RelativeDate.h"
#import "utilities.h"

#define kdate @"date"
#define kcourse @"course"
#define kdistance @"distance"
#define kname @"name"
#define kwaterway @"waterway"

#define kauthor @"author"

#define decode(x) self.x = [dec decodeObjectForKey:k ## x]
#define encode(x) [enc encodeObject:self.x forKey:k ## x]

#define encodeLink(x) [enc encodeObject:self.x.name forKey: k ## x]

@implementation Course (Import)

-(Course*)initWithCoder:(NSCoder*)dec {
    self = (Course*)[NSEntityDescription insertNewObjectForEntityForName:@"Course" inManagedObjectContext:Settings.sharedInstance.moc];
    if (self) {
        decode(date);
        decode(course);
        decode(distance);
        decode(name);
        decode(waterway);
    }
    return self;
}

// not encoding other Core Data objecs: boat, rowers, coxswain, course
-(void)encodeWithCoder:(NSCoder *)enc {
    encode(date);
    encode(course);
    encode(distance);
    encode(name);
    encode(waterway);
}

// This is really an export function, I wil have to rename the class...
-(BOOL)writeKML:(NSURL *)file {
    XMLWriter * x = [[XMLWriter alloc] init];
    CourseData * courseData = (CourseData*)[NSKeyedUnarchiver unarchiveObjectWithData:self.course];
    [x writeStartDocumentWithEncodingAndVersion:@"UTF-8" version:@"1.0"];
    [x writeStartElement:@"kml"]; {
        [x writeAttribute:@"xmlns" value:@"http://www.opengis.net/kml/2.2"];
        [x writeStartElement:@"Document"]; {
            [x writeFullElement:@"name" data:defaultName(self.name, @"Course")];
            if (self.waterway) [x writeFullElement:@"description" data:self.waterway];
            [x writeStartElement:@"Style"]; {
                [x writeAttribute:@"id" value:@"trackStyle"];
                [x writeStartElement:@"LineStyle"];
                [x writeFullElement:@"color" data:@"ff00ff00"];
                [x writeFullElement:@"width" data:@"6"];
                [x writeEndElement];
            }
            [x writeEndElement]; // Style
            [x writeStartElement:@"Placemark"]; {
                NSDate * date = self.date!=nil ? self.date : [NSDate date];
                [x writeFullElement:@"name" data:defaultName(self.waterway, @"Unknown waterway")];
                [x writeStartElement:@"description"]; {
                    NSString * cdata = [NSString stringWithFormat:@"<p>Distance: %@<br>Date: %@<br>Number of pins: %d</p>",dispLength(self.distance.floatValue),[date mediumshortDateTime], courseData.annotations.count];
                    [x writeCData:cdata];
                } [x writeEndElement]; // description
                [x writeFullElement:@"styleUrl" data:@"#trackStyle"];
                [x writeStartElement:@"LineString"]; {
                    [x writeFullElement:@"extrude" data:@"0"];
                    [x writeFullElement:@"tessellate" data:@"1"];
                    [x writeStartElement:@"coordinates"]; {
                        for (CourseAnnotation * a in courseData.annotations) {
                            [[x writeLinebreak] writeIndentation];
                            [x writeCharacters:[NSString stringWithFormat:@"%8.6f,%8.6f,0", a.coordinate.longitude, a.coordinate.latitude]];
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
    BOOL OK = [[x toString] writeToURL:file atomically:NO encoding:NSUTF8StringEncoding error:&error];
    if (!OK) {
        NSLog(@"%@", [error localizedDescription]);
    }
    return OK;
}



@end
