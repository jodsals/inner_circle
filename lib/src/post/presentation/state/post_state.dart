import 'package:equatable/equatable.dart';

import '../../domain/entities/post.dart';

/// Base state for posts
abstract class PostState extends Equatable {
  const PostState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class PostInitial extends PostState {
  const PostInitial();
}

/// Loading state
class PostLoading extends PostState {
  const PostLoading();
}

/// Posts loaded successfully
class PostsLoaded extends PostState {
  final List<Post> posts;

  const PostsLoaded(this.posts);

  @override
  List<Object?> get props => [posts];
}

/// Single post loaded successfully
class PostLoaded extends PostState {
  final Post post;

  const PostLoaded(this.post);

  @override
  List<Object?> get props => [post];
}

/// Post created successfully
class PostCreated extends PostState {
  final Post post;

  const PostCreated(this.post);

  @override
  List<Object?> get props => [post];
}

/// Post updated successfully
class PostUpdated extends PostState {
  final Post post;

  const PostUpdated(this.post);

  @override
  List<Object?> get props => [post];
}

/// Post deleted successfully
class PostDeleted extends PostState {
  const PostDeleted();
}

/// Error state
class PostError extends PostState {
  final String message;

  const PostError(this.message);

  @override
  List<Object?> get props => [message];
}
