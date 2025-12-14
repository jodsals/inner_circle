import 'package:equatable/equatable.dart';

import '../../domain/entities/comment.dart';

/// Base state for comments
abstract class CommentState extends Equatable {
  const CommentState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class CommentInitial extends CommentState {
  const CommentInitial();
}

/// Loading state
class CommentLoading extends CommentState {
  const CommentLoading();
}

/// Comments loaded successfully
class CommentsLoaded extends CommentState {
  final List<Comment> comments;

  const CommentsLoaded(this.comments);

  @override
  List<Object?> get props => [comments];
}

/// Comment created successfully
class CommentCreated extends CommentState {
  final Comment comment;

  const CommentCreated(this.comment);

  @override
  List<Object?> get props => [comment];
}

/// Comment updated successfully
class CommentUpdated extends CommentState {
  final Comment comment;

  const CommentUpdated(this.comment);

  @override
  List<Object?> get props => [comment];
}

/// Comment deleted successfully
class CommentDeleted extends CommentState {
  const CommentDeleted();
}

/// Error state
class CommentError extends CommentState {
  final String message;

  const CommentError(this.message);

  @override
  List<Object?> get props => [message];
}
