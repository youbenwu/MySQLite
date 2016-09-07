//
//  ClassInfo.h
//  DataBinding
//
//  Created by youbenwu on 16/7/11.
//  Copyright © 2016年 youbenwu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN


typedef NS_OPTIONS(NSUInteger, EncodingType) {
    EncodingTypeMask       = 0xFF, ///< mask of type value
    EncodingTypeUnknown    = 0, ///< unknown
    EncodingTypeVoid       = 1, ///< void
    EncodingTypeBool       = 2, ///< bool
    EncodingTypeInt8       = 3, ///< char / BOOL
    EncodingTypeUInt8      = 4, ///< unsigned char
    EncodingTypeInt16      = 5, ///< short
    EncodingTypeUInt16     = 6, ///< unsigned short
    EncodingTypeInt32      = 7, ///< int
    EncodingTypeUInt32     = 8, ///< unsigned int
    EncodingTypeInt64      = 9, ///< long long
    EncodingTypeUInt64     = 10, ///< unsigned long long
    EncodingTypeFloat      = 11, ///< float
    EncodingTypeDouble     = 12, ///< double
    EncodingTypeLongDouble = 13, ///< long double
    EncodingTypeObject     = 14, ///< id
    EncodingTypeClass      = 15, ///< Class
    EncodingTypeSEL        = 16, ///< SEL
    EncodingTypeBlock      = 17, ///< block
    EncodingTypePointer    = 18, ///< void*
    EncodingTypeStruct     = 19, ///< struct
    EncodingTypeUnion      = 20, ///< union
    EncodingTypeCString    = 21, ///< char*
    EncodingTypeCArray     = 22, ///< char[10] (for example)
    
    EncodingTypeQualifierMask   = 0xFF00,   ///< mask of qualifier
    EncodingTypeQualifierConst  = 1 << 8,  ///< const
    EncodingTypeQualifierIn     = 1 << 9,  ///< in
    EncodingTypeQualifierInout  = 1 << 10, ///< inout
    EncodingTypeQualifierOut    = 1 << 11, ///< out
    EncodingTypeQualifierBycopy = 1 << 12, ///< bycopy
    EncodingTypeQualifierByref  = 1 << 13, ///< byref
    EncodingTypeQualifierOneway = 1 << 14, ///< oneway
    
    EncodingTypePropertyMask         = 0xFF0000, ///< mask of property
    EncodingTypePropertyReadonly     = 1 << 16, ///< readonly
    EncodingTypePropertyCopy         = 1 << 17, ///< copy
    EncodingTypePropertyRetain       = 1 << 18, ///< retain
    EncodingTypePropertyNonatomic    = 1 << 19, ///< nonatomic
    EncodingTypePropertyWeak         = 1 << 20, ///< weak
    EncodingTypePropertyCustomGetter = 1 << 21, ///< getter=
    EncodingTypePropertyCustomSetter = 1 << 22, ///< setter=
    EncodingTypePropertyDynamic      = 1 << 23, ///< @dynamic
};


/**
 Get the type from a Type-Encoding string.
 
 @discussion See also:
 https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
 https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html
 
 @param typeEncoding  A Type-Encoding string.
 @return The encoding type.
 */
EncodingType EncodingGetType(const char *typeEncoding);


@interface IvarInfo : NSObject

@property (nonatomic, assign, readonly) Ivar ivar;              ///< ivar opaque struct
@property (nonatomic, strong, readonly) NSString *name;         ///< Ivar's name
@property (nonatomic, assign, readonly) ptrdiff_t offset;       ///< Ivar's offset
@property (nonatomic, strong, readonly) NSString *typeEncoding; ///< Ivar's type encoding
@property (nonatomic, assign, readonly) EncodingType type;    ///< Ivar's type


/**
 Creates and returns an ivar info object.
 
 @param ivar ivar opaque struct
 @return A new object, or nil if an error occurs.
 */
- (instancetype)initWithIvar:(Ivar)ivar;

@end

@interface MethodInfo : NSObject

@property (nonatomic, assign, readonly) Method method;                  ///< method opaque struct
@property (nonatomic, strong, readonly) NSString *name;                 ///< method name
@property (nonatomic, assign, readonly) SEL sel;                        ///< method's selector
@property (nonatomic, assign, readonly) IMP imp;                        ///< method's implementation
@property (nonatomic, strong, readonly) NSString *typeEncoding;         ///< method's parameter and return types
@property (nonatomic, strong, readonly) NSString *returnTypeEncoding;   ///< return value's type
@property (nullable, nonatomic, strong, readonly) NSArray<NSString *> *argumentTypeEncodings; ///< array of arguments' type

/**
 Creates and returns a method info object.
 
 @param method method opaque struct
 @return A new object, or nil if an error occurs.
 */
- (instancetype)initWithMethod:(Method)method;

@end


@interface PropertyInfo : NSObject


@property (nonatomic, assign, readonly) objc_property_t property; ///< property's opaque struct
@property (nonatomic, strong, readonly) NSString *name;           ///< property's name
@property (nonatomic, assign, readonly) EncodingType type;      ///< property's type
@property (nonatomic, strong, readonly) NSString *typeEncoding;   ///< property's encoding value
@property (nonatomic, strong, readonly) NSString *ivarName;       ///< property's ivar name
@property (nullable, nonatomic, assign, readonly) Class cls;      ///< may be nil
@property (nullable, nonatomic, strong, readonly) NSArray<NSString *> *protocols; ///< may nil
@property (nonatomic, assign, readonly) SEL getter;               ///< getter (nonnull)
@property (nonatomic, assign, readonly) SEL setter;               ///< setter (nonnull)

/**
 Creates and returns a property info object.
 
 @param property property opaque struct
 @return A new object, or nil if an error occurs.
 */
- (instancetype)initWithProperty:(objc_property_t)property;

@end

@interface ClassInfo : NSObject

@property (nonatomic, assign, readonly) Class cls; ///< class object
@property (nullable, nonatomic, assign, readonly) Class superCls; ///< super class object
@property (nullable, nonatomic, assign, readonly) Class metaCls;  ///< class's meta class object
@property (nonatomic, readonly) BOOL isMeta; ///< whether this class is meta class
@property (nonatomic, strong, readonly) NSString *name; ///< class name
@property (nullable, nonatomic, strong, readonly) ClassInfo *superClassInfo; ///< super class's class info
@property (nullable, nonatomic, strong, readonly) NSDictionary<NSString *, IvarInfo *> *ivarInfos; ///< ivars
@property (nullable, nonatomic, strong, readonly) NSDictionary<NSString *, MethodInfo *> *methodInfos; ///< methods
@property (nullable, nonatomic, strong, readonly) NSDictionary<NSString *, PropertyInfo *> *propertyInfos; ///< properties


/**
 If the class is changed (for example: you add a method to this class with
 'class_addMethod()'), you should call this method to refresh the class info cache.
 
 After called this method, `needUpdate` will returns `YES`, and you should call
 'classInfoWithClass' or 'classInfoWithClassName' to get the updated class info.
 */
- (void)setNeedUpdate;

/**
 If this method returns `YES`, you should stop using this instance and call
 `classInfoWithClass` or `classInfoWithClassName` to get the updated class info.
 
 @return Whether this class info need update.
 */
- (BOOL)needUpdate;

/**
 Get the class info of a specified Class.
 
 @discussion This method will cache the class info and super-class info
 at the first access to the Class. This method is thread-safe.
 
 @param cls A class.
 @return A class info, or nil if an error occurs.
 */
+ (nullable instancetype)classInfoWithClass:(Class)cls;

/**
 Get the class info of a specified Class.
 
 @discussion This method will cache the class info and super-class info
 at the first access to the Class. This method is thread-safe.
 
 @param className A class name.
 @return A class info, or nil if an error occurs.
 */
+ (nullable instancetype)classInfoWithClassName:(NSString *)className;


@end


NS_ASSUME_NONNULL_END
