/*
 * Copyright (c) 2006 Dave Dribin
 * 
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use, copy,
 * modify, merge, publish, distribute, sublicense, and/or sell copies
 * of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
 * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
 * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#import "DDAudioComponent.h"
#import "DDAudioException.h"
#import "DDAudioCompatibility.h"

#define THROW_IF DDThrowAudioIfErr

@implementation DDAudioComponent

+ (NSArray *) componentsMatchingType: (OSType) type
                             subType: (OSType) subType
                        manufacturer: (OSType) manufacturer;
{
    AudioComponentDescription description;
    description.componentType = type;
    description.componentSubType = subType;
    description.componentManufacturer = manufacturer;
    description.componentFlags = 0;
    description.componentFlagsMask = 0;
    
    return [self componentsMatchingDescription: &description];
}

+ (NSArray *) componentsMatchingDescription: (AudioComponentDescription *) description;
{
    UInt32 componentCount = AudioComponentCount(description);
    NSMutableArray * components =
        [NSMutableArray arrayWithCapacity: componentCount];
    AudioComponent current = 0;
    do
    {
        NSAutoreleasePool * loopPool = [[NSAutoreleasePool alloc] init];
        current = AudioComponentFindNext(current, description);
        if (current != 0)
        {
            DDAudioComponent * component =
            [[DDAudioComponent alloc] initWithComponent: current];
            [components addObject: component];
            [component release];
        }
        [loopPool release];
    } while (current != 0);
    
    return components;
}

+ (void) printComponents;
{
    OSType types[] = {
        kAudioUnitType_Output,
        kAudioUnitType_MusicDevice,
        kAudioUnitType_MusicEffect,
        kAudioUnitType_FormatConverter,
        kAudioUnitType_Effect,
        kAudioUnitType_Mixer,
        kAudioUnitType_Panner,
        kAudioUnitType_Generator,
        kAudioUnitType_OfflineEffect,
    };
    for (int i = 0; i < (sizeof(types)/sizeof(*types)); i++) {
        OSType type = types[i];
        [self printComponentsMatchingType:type];
    }
}

+ (NSString *)stringForOSType:(OSType)type
{
    NSString * string = NSMakeCollectable(UTCreateStringForOSType(type));
    return [string autorelease];
}

+ (void) printComponentsMatchingType: (OSType) type;
{
    NSArray * components = [self componentsMatchingType: type
                                                subType: 0
                                           manufacturer: 0];
    
    NSEnumerator * e = [components objectEnumerator];
    DDAudioComponent * component;
    while (component = [e nextObject])
    {
        AudioComponentDescription description = [component AudioComponentDescription];
        NSString * type = [self stringForOSType:description.componentType];
        NSString * subType = [self stringForOSType:description.componentSubType];
        NSString * manufacturer = [self stringForOSType:description.componentManufacturer];
        
        NSLog(@"Compoment %@ %@ %@: %@ by %@", type, subType, manufacturer,
              [component name], [component manufacturer]);
    }
}

- (id) initWithComponent: (AudioComponent) component;
{
    self = [super init];
    if (self == nil)
        return nil;
    
    mComponent = component;
    mManufacturer = @"";
    mName = @"";
    
    THROW_IF(AudioComponentGetDescription(component, &mDescription));
    
    CFStringRef cfFullName = NULL;
    THROW_IF(AudioComponentCopyName(component, &cfFullName));
    NSString * fullName = [NSMakeCollectable(cfFullName) autorelease];
    
    NSRange colonRange = [fullName rangeOfString: @":"];
    if (colonRange.location != NSNotFound)
    {
        mManufacturer = [fullName substringToIndex: colonRange.location];
        mName = [fullName substringFromIndex: colonRange.location + 1];
        mName = [mName stringByTrimmingCharactersInSet:
            [NSCharacterSet whitespaceCharacterSet]];
        
        [mManufacturer retain];
        [mName retain];
    }
    else
    {
        mManufacturer = @"";
        mName = [fullName copy];
    }
    
    return self;
}

- (void)dealloc
{
    [mManufacturer release];
    [mName release];
    [super dealloc];
}


- (AudioComponent) AudioComponent;
{
    return mComponent;
}

- (AudioComponentDescription) AudioComponentDescription;
{
    return mDescription;
}

- (NSString *) manufacturer;
{
    return mManufacturer;
}

- (NSString *) name;
{
    return mName;
}


@end
