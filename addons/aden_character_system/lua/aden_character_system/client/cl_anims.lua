function Aden_DC.ClientSideMenu:runExit(exit, callback)
    self.isExit = true
    if IsValid(self.playerRagdoll) then
        for k, v in ipairs(self.showRoom) do
            if IsValid(v) then
                v:SetParent()
            end
        end
        local angEnd = Angle(0, 20, 0) + Angle(0, 180, 0)
        local posStart = self.playerRagdoll:GetPos()
        local coolDown = CurTime() + 0.5
        timer.Simple(0.5, function()
            if !IsValid(self.playerRagdoll) then return end
            local idSeq = self.playerRagdoll:LookupSequence("walk_all_moderate")
            if idSeq == -1 then
                idSeq = self.playerRagdoll:LookupSequence("menu_walk")
            end
            self.playerRagdoll:ResetSequence(idSeq)
            self.playerRagdoll:SetPlaybackRate(0.8)
        end)
        hook.Add("Think", "Think::ADC::FrameAdvance", function()
            if !IsValid(self.playerRagdoll) then
                hook.Remove("Think", "Think::ADC::FrameAdvance")
                return
            end
            self.playerRagdoll:SetAngles(LerpAngle(0.015, self.playerRagdoll:GetAngles(), angEnd))
            if coolDown > CurTime() then return end
            posStart.x = posStart.x - 30 / (1 / FrameTime())
            posStart.y = posStart.y - 15 / (1 / FrameTime())
            self.playerRagdoll:SetPos(posStart)
            self.playerRagdoll:FrameAdvance(FrameTime()) // Check DModelPanel github
        end)
    end
    Aden_DC.Buttons:removeView("Menu")
    Aden_DC.Buttons:removeView("Informations")
    timer.Simple(3, function() // Anti-block
        hook.Remove("Think", "Think::ADC::FrameAdvance")
        self.isExit = false
        if exit then
            self:exitMenu()
        end
        callback()
    end)
end
