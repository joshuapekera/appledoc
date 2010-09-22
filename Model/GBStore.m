//
//  GBStore.m
//  appledoc
//
//  Created by Tomaz Kragelj on 25.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "GBDataObjects.h"
#import "GBStore.h"

@implementation GBStore

#pragma mark Initialization & disposal

- (id)init {
	self = [super init];
	if (self) {
		_classes = [[NSMutableSet alloc] init];
		_classesByName = [[NSMutableDictionary alloc] init];
		_categories = [[NSMutableSet alloc] init];
		_categoriesByName = [[NSMutableDictionary alloc] init];
		_protocols = [[NSMutableSet alloc] init];
		_protocolsByName = [[NSMutableDictionary alloc] init];
	}
	return self;
}

#pragma mark Overriden methods

- (NSString *)description {
	return [NSString stringWithFormat:@"%@ with %u classes, %u categories, %u protocols", [self className], [self.classes count], [self.categories count], [self.protocols count]];
}

#pragma mark Helper methods

- (NSArray *)classesSortedByName {
	NSArray *descriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"nameOfClass" ascending:YES]];
	return [[self.classes allObjects] sortedArrayUsingDescriptors:descriptors];
}

- (NSArray *)categoriesSortedByName {
	NSSortDescriptor *classNameDescription = [NSSortDescriptor sortDescriptorWithKey:@"nameOfClass" ascending:YES];
	NSSortDescriptor *categoryNameDescription = [NSSortDescriptor sortDescriptorWithKey:@"categoryName" ascending:YES];
	NSArray *descriptors = [NSArray arrayWithObjects:classNameDescription, categoryNameDescription, nil];
	return [[self.categories allObjects] sortedArrayUsingDescriptors:descriptors];
}

- (NSArray *)protocolsSortedByName {
	NSArray *descriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"protocolName" ascending:YES]];
	return [[self.protocols allObjects] sortedArrayUsingDescriptors:descriptors];
}

#pragma mark GBStoreProviding implementation

- (void)registerClass:(GBClassData *)class {
	NSParameterAssert(class != nil);
	GBLogDebug(@"Registering class %@...", class);
	if ([_classes containsObject:class]) return;
	GBClassData *existingClass = [_classesByName objectForKey:class.nameOfClass];
	if (existingClass) {
		[existingClass mergeDataFromObject:class];
		return;
	}
	[_classes addObject:class];
	[_classesByName setObject:class forKey:class.nameOfClass];
}

- (void)registerCategory:(GBCategoryData *)category {
	NSParameterAssert(category != nil);
	GBLogDebug(@"Registering category %@...", category);
	if ([_categories containsObject:category]) return;
	NSString *categoryID = [NSString stringWithFormat:@"%@(%@)", category.nameOfClass, category.nameOfCategory ? category.nameOfCategory : @""];
	GBCategoryData *existingCategory = [_categoriesByName objectForKey:categoryID];
	if (existingCategory) {
		[existingCategory mergeDataFromObject:category];
		return;
	}
	[_categories addObject:category];
	[_categoriesByName setObject:category forKey:categoryID];
}

- (void)registerProtocol:(GBProtocolData *)protocol {
	NSParameterAssert(protocol != nil);
	GBLogDebug(@"Registering class %@...", protocol);
	if ([_protocols containsObject:protocol]) return;
	GBProtocolData *existingProtocol = [_protocolsByName objectForKey:protocol.nameOfProtocol];
	if (existingProtocol) {
		[existingProtocol mergeDataFromObject:protocol];
		return;
	}
	[_protocols addObject:protocol];
	[_protocolsByName setObject:protocol forKey:protocol.nameOfProtocol];
}

- (GBClassData *)classByName:(NSString *)name {
	return [_classesByName objectForKey:name];
}

- (GBCategoryData *)categoryByName:(NSString *)name {
	return [_categoriesByName objectForKey:name];
}

- (GBProtocolData *)protocolByName:(NSString *)name {
	return [_protocolsByName objectForKey:name];
}

@synthesize classes = _classes;
@synthesize categories = _categories;
@synthesize protocols = _protocols;

@end