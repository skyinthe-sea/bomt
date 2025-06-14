import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  // Supabase 초기화
  await Supabase.initialize(
    url: 'https://vqvygrbklxgfutwpfugs.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZxdnlncmJrbHhnZnV0d3BmdWdzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTgzMzU3MjQsImV4cCI6MjAzMzkxMTcyNH0.YOZOCq5wMQBnIriHQy8t7Jb_NVMAZDrGpCnK-91x0is',
  );

  final supabase = Supabase.instance.client;

  print('=== Community Database 체크 시작 ===\n');

  try {
    // 1. 카테고리 테이블 체크
    print('1. 카테고리 테이블 체크...');
    final categoriesResponse = await supabase
        .from('community_categories')
        .select()
        .order('display_order');
    
    print('카테고리 수: ${categoriesResponse.length}개');
    for (final category in categoriesResponse) {
      print('  - ID: ${category['id']}, Name: ${category['name']}, Slug: ${category['slug']}, Active: ${category['is_active']}');
    }
    print('');

    // 2. 게시글 테이블 체크
    print('2. 게시글 테이블 체크...');
    final postsResponse = await supabase
        .from('community_posts')
        .select()
        .eq('is_deleted', false)
        .limit(10);
    
    print('게시글 수: ${postsResponse.length}개 (최대 10개 표시)');
    for (final post in postsResponse) {
      print('  - ID: ${post['id']}');
      print('    Title: ${post['title']}');
      print('    Category ID: ${post['category_id']}');
      print('    Author ID: ${post['author_id']}');
      print('    Created: ${post['created_at']}');
      print('');
    }

    // 3. category_id가 null인 게시글 체크
    print('3. category_id가 null인 게시글 체크...');
    final nullCategoryPosts = await supabase
        .from('community_posts')
        .select('id, title, category_id')
        .filter('category_id', 'is', null)
        .eq('is_deleted', false);
    
    if (nullCategoryPosts.isNotEmpty) {
      print('경고: category_id가 null인 게시글 발견!');
      for (final post in nullCategoryPosts) {
        print('  - ID: ${post['id']}, Title: ${post['title']}');
      }
    } else {
      print('모든 게시글이 category_id를 가지고 있습니다.');
    }
    print('');

    // 4. 유효하지 않은 category_id를 가진 게시글 체크
    print('4. 유효하지 않은 category_id를 가진 게시글 체크...');
    final categoryIds = (categoriesResponse as List).map((c) => c['id']).toList();
    final allPosts = await supabase
        .from('community_posts')
        .select('id, title, category_id')
        .eq('is_deleted', false);
    
    final invalidCategoryPosts = (allPosts as List).where((post) {
      return post['category_id'] != null && !categoryIds.contains(post['category_id']);
    }).toList();
    
    if (invalidCategoryPosts.isNotEmpty) {
      print('경고: 유효하지 않은 category_id를 가진 게시글 발견!');
      for (final post in invalidCategoryPosts) {
        print('  - ID: ${post['id']}, Title: ${post['title']}, Invalid Category ID: ${post['category_id']}');
      }
    } else {
      print('모든 게시글이 유효한 category_id를 가지고 있습니다.');
    }
    print('');

    // 5. 사용자 프로필 체크
    print('5. 사용자 프로필 테이블 체크...');
    final profilesResponse = await supabase
        .from('user_profiles')
        .select()
        .limit(5);
    
    print('사용자 프로필 수: ${profilesResponse.length}개 (최대 5개 표시)');
    for (final profile in profilesResponse) {
      print('  - User ID: ${profile['user_id']}, Nickname: ${profile['nickname']}');
    }

  } catch (e, stackTrace) {
    print('에러 발생: $e');
    print('스택 트레이스: $stackTrace');
  }

  print('\n=== 체크 완료 ===');
  
  // 프로그램 종료
  exit(0);
}

// exit 함수를 위한 import
void exit(int code) {
  // Dart 스크립트에서는 자동으로 종료됨
}