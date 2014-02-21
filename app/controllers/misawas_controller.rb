class MisawasController < ApplicationController
    def index
        misawa = Misawa.new()
        eid = misawa.getRandomId
        rets = misawa.getImage(eid)
        @imgUrl = rets[0]
        @pageUrl = rets[1]
    end
end
