module RedmineWatchersGroups
  module WatchersControllerPatch

    def create
      group_ids = []
      if params[:watcher]
        group_ids << (params[:watcher][:user_ids] || params[:watcher][:user_id])
      else
        group_ids << params[:user_id]
      end

      groups = Group.active.visible.where(id: group_ids.flatten.compact.uniq)

      groups.each do |group|
        @watchables.each do |watchable|
          group.users.each do |user|
            Watcher.create(watchable: watchable, user: user)
          end
        end
      end

      super
    end

    def append
      if params[:watcher]
        user_ids = params[:watcher][:user_ids] || [params[:watcher][:user_id]]
        users = User.active.visible.where(id: user_ids.flatten.compact.uniq)
        groups = Group.active.visible.where(id: user_ids.flatten.compact.uniq)
        @users = (users + groups).to_a
      end

      if @users.blank?
        head 200
      end
    end

    def destroy
      if Group.exists?(id: params[:user_id])
        group = Group.find(params[:user_id])

        group.users.each do |user|
          @watchables.each do |watchable|
            watchable.set_watcher(user, false)
          end
        end

        respond_to do |format|
          format.html { redirect_to_referer_or { render html: 'Watcher Group removed.', status: 200, layout: true} }
          format.js
          format.api { render_api_ok }
        end
      else
        super
      end
    end

    private

    def users_for_new_watcher
      users = super
      if params[:q].blank? && @project.present?
        scope = @project.groups
      else
        scope = Group.all.limit(100)
      end
      groups = scope.active.visible.sorted.like(params[:q]).to_a

      if @watchables && @watchables.size == 1
        watcher_ids = @watchables.first.watchers.map(&:user_id)
      else
        watcher_ids = []
      end

      watcher_groups = Group.watcher_groups(watcher_ids)

      groups -= watcher_groups

      users + groups
    end

  end
end
