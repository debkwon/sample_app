module MicropostsHelper
	 def micropost_params
      params.require(:micropost).permit(:content, :picture)
    end
end
