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

#import "DDAudioUnitGraph.h"
#import "DDAudioUnitNode.h"
#import "DDAudioException.h"
#import "DDAudioComponent.h"

#define THROW_IF DDThrowAudioIfErr

@implementation DDAudioUnitGraph

- (id) init;
{
    self = [super init];
    if (self == nil)
        return nil;
    
    THROW_IF(NewAUGraph(&mGraph));
   
    return self;
}

- (void) dealloc;
{
    DisposeAUGraph(mGraph);
    [super dealloc];
}

- (AUGraph) AUGraph;
{
    return mGraph;
}

- (DDAudioUnitNode *) addNodeWithType: (OSType) type
                              subType: (OSType) subType;
{
    return [self addNodeWithType: type
                         subType: subType
                    manufacturer: kAudioUnitManufacturer_Apple];
}

- (DDAudioUnitNode *) addNodeWithType: (OSType) type
                              subType: (OSType) subType
                         manufacturer: (OSType) manufacturer;
{
    AudioComponentDescription description;
    description.componentType = type;
    description.componentSubType = subType;
    description.componentManufacturer = manufacturer;
    description.componentFlags = 0;
    description.componentFlagsMask = 0;
    return [self addNodeWithDescription: &description];
}

- (DDAudioUnitNode *) addNodeWithDescription: (AudioComponentDescription *) description;
{
    AUNode node;
    THROW_IF(AUGraphAddNode(mGraph, description, &node));
    return [[[DDAudioUnitNode alloc] initWithAUNode: node inGraph: self] autorelease];
}

- (DDAudioUnitNode *) addNodeWithComponent: (DDAudioComponent *) component;
{
    AudioComponentDescription description = [component AudioComponentDescription];
    return [self addNodeWithDescription: &description];
}

- (void) removeNode: (DDAudioUnitNode *) node;
{
    THROW_IF(AUGraphRemoveNode(mGraph, [node AUNode]));
}

- (void) connectNode: (DDAudioUnitNode *) sourceNode
              output: (UInt32) sourceOutput
              toNode: (DDAudioUnitNode *) destNode
               input: (UInt32) destInput;
{
    THROW_IF(AUGraphConnectNodeInput(mGraph,
                                     [sourceNode AUNode], sourceOutput,
                                     [destNode AUNode], destInput));
}


- (void) disconnectNode: (DDAudioUnitNode *) node
                  input: (UInt32) input;
{
    THROW_IF(AUGraphDisconnectNodeInput(mGraph,
                                        [node AUNode], input));
}

- (void) disconnectAll;
{
    THROW_IF(AUGraphClearConnections(mGraph));
}

- (void) open;
{
    THROW_IF(AUGraphOpen(mGraph));
}

- (void) close;
{
    THROW_IF(AUGraphClose(mGraph));
}

- (void) update;
{
    THROW_IF(AUGraphUpdate(mGraph, NULL));
}

- (void) initialize;
{
    THROW_IF(AUGraphInitialize(mGraph));
}

- (void) uninitialize;
{
    THROW_IF(AUGraphUninitialize(mGraph));
}

- (void) start;
{
    THROW_IF(AUGraphStart(mGraph));
}

- (void) stop;
{
    THROW_IF(AUGraphStop(mGraph));
}

- (BOOL) isRunning;
{
    Boolean isRunning;
    THROW_IF(AUGraphIsRunning(mGraph, &isRunning));
    return isRunning;
}

- (float) cpuLoad;
{
    Float32 cpuLoad;
    THROW_IF(AUGraphGetCPULoad(mGraph, &cpuLoad));
    return (float) cpuLoad;
}

- (NSString *) description
{
    return DDCoreAudioShowObjectToString(mGraph);
}

@end

static int dataWrite(void * context, const char * buffer, int count)
{
    NSMutableData * descriptionData = context;
    [descriptionData appendBytes:buffer length:count];
    return 0;
}

NSString * DDCoreAudioShowObjectToString(void * object)
{
    NSMutableData * descriptionData = [NSMutableData data];
    FILE * inMemoryFile = fwopen(descriptionData, dataWrite);
    CAShowFile(object, inMemoryFile);
    fclose(inMemoryFile);
    
    NSString * description = [[NSString alloc] initWithData:descriptionData encoding:NSUTF8StringEncoding];
    return [description autorelease];
}
