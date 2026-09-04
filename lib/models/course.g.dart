// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Course _$CourseFromJson(Map<String, dynamic> json) => Course(
      courseId: json['course_id'] as String?,
      idCourse: json['idCourse'] as String?,
      code: json['code'] as String?,
      courseName: json['course_name'] as String?,
      name: json['name'] as String?,
      courseDescription: json['course_description'] as String?,
      courseBoxDescription: json['course_box_description'] as String?,
      status: json['status'] as String?,
      selling: json['selling'] as String?,
      price: json['price'] as String?,
      subscribeMethod: json['subscribe_method'] as String?,
      unsubscribeMethod: json['unsubscribe_method'] as String?,
      courseEdition: json['course_edition'] as String?,
      courseType: json['course_type'] as String?,
      canSubscribe: json['can_subscribe'] as String?,
      subStartDate: json['sub_start_date'] as String?,
      subEndDate: json['sub_end_date'] as String?,
      dateBegin: json['date_begin'] as String?,
      dateEnd: json['date_end'] as String?,
      courseLink: json['course_link'] as String?,
      imgCourse: json['img_course'] as String?,
      categoryId: json['category_id'] as String?,
      category: json['category'] as String?,
      enrolled: json['enrolled'],
      courseImage: json['course_image'] as String?,
      userStatus: json['user_status'] as String?,
      isEnrolled: json['is_enrolled'] as bool?,
      canEnter: json['canEnter'] as bool?,
      courseBoxEnabled: json['courseBoxEnabled'] as bool?,
      userCanUnsubscribe: json['userCanUnsubscribe'] as bool?,
      canEnter1: json['can_enter'] == null
          ? null
          : CanEnter.fromJson(json['can_enter'] as Map<String, dynamic>),
      dateSubscribed: json['date_subscribed'] as String?,
      dateFirstAccess: json['date_first_access'] as String?,
      courseStats: json['course_stats'] == null
          ? null
          : CourseStats.fromJson(json['course_stats'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CourseToJson(Course instance) => <String, dynamic>{
      'course_id': instance.courseId,
      'idCourse': instance.idCourse,
      'code': instance.code,
      'course_name': instance.courseName,
      'name': instance.name,
      'course_description': instance.courseDescription,
      'course_box_description': instance.courseBoxDescription,
      'status': instance.status,
      'selling': instance.selling,
      'price': instance.price,
      'subscribe_method': instance.subscribeMethod,
      'unsubscribe_method': instance.unsubscribeMethod,
      'course_edition': instance.courseEdition,
      'course_type': instance.courseType,
      'can_subscribe': instance.canSubscribe,
      'sub_start_date': instance.subStartDate,
      'sub_end_date': instance.subEndDate,
      'date_begin': instance.dateBegin,
      'date_end': instance.dateEnd,
      'course_link': instance.courseLink,
      'img_course': instance.imgCourse,
      'category_id': instance.categoryId,
      'category': instance.category,
      'enrolled': instance.enrolled,
      'course_image': instance.courseImage,
      'user_status': instance.userStatus,
      'is_enrolled': instance.isEnrolled,
      'canEnter': instance.canEnter,
      'courseBoxEnabled': instance.courseBoxEnabled,
      'userCanUnsubscribe': instance.userCanUnsubscribe,
      'can_enter': instance.canEnter1,
      'date_subscribed': instance.dateSubscribed,
      'date_first_access': instance.dateFirstAccess,
      'course_stats': instance.courseStats,
    };
