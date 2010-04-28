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

#import <Foundation/Foundation.h>
#import <AudioUnit/AudioUnit.h>

@class AUGenericView;
@class DDAudioUnitPreset;

@interface DDAudioUnit : NSObject
{
    AudioUnit mAudioUnit;
    NSMutableArray * mFactoryPresets;
}

- (id) initWithAudioUnit: (AudioUnit) audioUnit;

- (AudioUnit) AudioUnit;

- (void) setRenderCallback: (AURenderCallback) callback
                   context: (void *) context;

- (void) setBypass: (BOOL) bypass;

- (BOOL) bypass;

- (void) setStreamFormatWithDescription: (const AudioStreamBasicDescription *) streamFormat;

- (void) setParameter: (AudioUnitParameterID) parameter
                scope: (AudioUnitScope) scope
              element: (AudioUnitElement) element
                value: (Float32) value
         bufferOffset: (UInt32) bufferOffset;

- (Float32) getParameter: (AudioUnitParameterID) parameter
                   scope: (AudioUnitScope) scope
                 element: (AudioUnitElement) element;

#pragma mark -
#pragma mark Presets

- (NSArray *) factoryPresets;

- (NSUInteger) indexOfFactoryPreset: (DDAudioUnitPreset *) presetToFind;

- (DDAudioUnitPreset *) presentPreset;
- (void) setPresentPreset: (DDAudioUnitPreset *) presentPreset;

- (unsigned) presentPresetIndex;
- (void) setPresentPresetIndex: (unsigned) presentPresetIndex;

#if !TARGET_OS_IPHONE

#pragma mark -
#pragma mark View

- (NSView *) createViewWithSize: (NSSize) size;

- (BOOL) hasCustomCocoaView;

- (NSView *) createCustomCocoaViewWithSize: (NSSize) defaultSize;

- (AUGenericView *) createGenericView;

#endif

@end

#if !TARGET_OS_IPHONE
# define kAudioUnitSubType_DDDefaultOutput kAudioUnitSubType_DefaultOutput
#else
# define kAudioUnitSubType_DDDefaultOutput kAudioUnitSubType_RemoteIO
#endif
