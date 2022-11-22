class PostsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create, :destroy]

  def index
    @user = User.find(params[:user_id])
    @posts = @user.posts
  end

  def new
    @post = Post.new
  end

  def create
    @post = current_user.posts.build(post_params)
    if @post.save
      redirect_to user_posts_path
    else
      render action: :new
    end
  end

  def destroy
  end

  private

  def post_params
    params.require(:post).permit(:disaster, :date, :locate, :content)
  end
end
