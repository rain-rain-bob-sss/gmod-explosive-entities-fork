--[[
	todo:
		
		The tool name and descriptions look bugged. 
		Toggleable debris
		
		Adjustable debris size
		Adjustable explosion size
		Adjustable blast radius
		Adjustable z velocity as well as halve it
		Adjustable delay
]]

ee = {}

do -- downloads
	if SERVER then
		resource.AddFile("materials/modulus/particles/Smoke1.vmt")
		resource.AddFile("materials/modulus/particles/Smoke2.vmt")
		resource.AddFile("materials/modulus/particles/Smoke3.vmt")
		resource.AddFile("materials/modulus/particles/Smoke4.vmt")
		resource.AddFile("materials/modulus/particles/Smoke5.vmt")
		resource.AddFile("materials/modulus/particles/Smoke6.vmt")

		resource.AddFile("materials/modulus/particles/Fire1.vmt")
		resource.AddFile("materials/modulus/particles/Fire2.vmt")
		resource.AddFile("materials/modulus/particles/Fire3.vmt")
		resource.AddFile("materials/modulus/particles/Fire4.vmt")
		resource.AddFile("materials/modulus/particles/Fire5.vmt")
		resource.AddFile("materials/modulus/particles/Fire6.vmt")
		resource.AddFile("materials/modulus/particles/Fire7.vmt")
		resource.AddFile("materials/modulus/particles/Fire8.vmt")

		resource.AddFile("materials/modulus/particles/Smoke1.vtf")
		resource.AddFile("materials/modulus/particles/Smoke2.vtf")
		resource.AddFile("materials/modulus/particles/Smoke3.vtf")
		resource.AddFile("materials/modulus/particles/Smoke4.vtf")
		resource.AddFile("materials/modulus/particles/Smoke5.vtf")
		resource.AddFile("materials/modulus/particles/Smoke6.vtf")

		resource.AddFile("materials/modulus/particles/Fire1.vtf")
		resource.AddFile("materials/modulus/particles/Fire2.vtf")
		resource.AddFile("materials/modulus/particles/Fire3.vtf")
		resource.AddFile("materials/modulus/particles/Fire4.vtf")
		resource.AddFile("materials/modulus/particles/Fire5.vtf")
		resource.AddFile("materials/modulus/particles/Fire6.vtf")
		resource.AddFile("materials/modulus/particles/Fire7.vtf")
		resource.AddFile("materials/modulus/particles/Fire8.vtf")
	end
end

do -- effects
	if CLIENT then
		local R = math.Rand
		
		do -- materials
			local smoke = 
			{
				"particle/smokesprites_0001",
				"particle/smokesprites_0002",
				"particle/smokesprites_0003",
				"particle/smokesprites_0004",
				"particle/smokesprites_0005",
				"particle/smokesprites_0006",
				"particle/smokesprites_0007",
				"particle/smokesprites_0008",
				"particle/smokesprites_0009",
				"particle/smokesprites_0010",
				"particle/smokesprites_0012",
				"particle/smokesprites_0013",
				"particle/smokesprites_0014",
				"particle/smokesprites_0015",
				"particle/smokesprites_0016",
			}

			function ee.GetMaterial(typ)
				if ee.use_custom_materials == nil then						
					if file.Exists("materials/modulus/particles/fire8.vtf", "GAME") then
						ee.use_custom_materials = true
					else
						ee.use_custom_materials = false
					end			
				end
			
				if ee.use_custom_materials == true then
					if typ == "fire" then
						return "modulus/particles/fire"..math.random(1,8)
					elseif typ == "smoke" then
						return "modulus/particles/smoke"..math.random(1,6)
					end
				elseif ee.use_custom_materials == false then
					if typ == "fire" then
						return "particles/flamelet" .. math.random(1,5)
					elseif typ == "smoke" then
						return table.Random(smoke)
					end
				end
			end
		end

		function ee.DrawSunBeams(pos, mult, siz)
			local ply = LocalPlayer()
			local eye = EyePos()
			
			if not util.QuickTrace(eye, pos-eye, {ply}).HitWorld then
				local spos = pos:ToScreen()
				DrawSunbeams(
					0, 
					math.Clamp(mult * (math.Clamp(ply:GetAimVector():DotProduct((pos - eye):GetNormalized()) - 0.5, 0, 1) * 2) ^ 5, 0, 1), 
					siz, 
					spos.x / ScrW(), 
					spos.y / ScrH()
				)
			end
		end
		
		hook.Add("RenderScreenspaceEffects", "ee", function()
			if GetConVarNumber("explosive_entities_sunbeams") == 1 then
				local ents = ents.FindByClass("ee_debris_entity")
				local count = #ents
				for key, ent in pairs(ents) do
					if ent:GetVelocity() ~= vector_origin then
						ee.DrawSunBeams(ent:GetPos(), 0.1/count, 0.5)
					else
						count = count - 1
					end
				end
			end
		end)
		
		do -- particles
			local emt = ParticleEmitter(vector_origin)
			local prt

			function ee.EmitExplosion(pos, size)
				size = math.max(size, 10) / 4
				
				emt:SetPos(pos)
				
				for i = 1, 30 do
					prt = emt:Add(ee.GetMaterial("smoke"), pos)
					prt:SetVelocity(VectorRand() * size * 10)
					prt:SetDieTime(R(5, 10))
					prt:SetStartAlpha(R(200, 255))
					prt:SetEndAlpha(0)
					prt:SetStartSize(size * 2)
					prt:SetEndSize(size * 4)
					prt:SetAirResistance(200)
					prt:SetRoll(R(-5, 5))
					prt:SetLighting(true)
					
					prt = emt:Add(ee.GetMaterial("fire"), pos)
					prt:SetVelocity(VectorRand() * size * 50) 		
					prt:SetDieTime(0.5) 		 
					prt:SetStartAlpha(R(200, 255)) 
					prt:SetEndAlpha(0) 	 
					prt:SetStartSize(size) 
					prt:SetEndSize(size * 5) 		 
					prt:SetRoll(R(-5, 5))
					prt:SetAirResistance(200) 
					--prt:SetLighting(true)
				end
				
				for i = 1, 50 do
					prt = emt:Add(ee.GetMaterial("smoke"), pos)
					prt:SetVelocity(VectorRand() * 30 * size)
					prt:SetDieTime(math.min((R(1, 3)*size) / 10, 3))
					prt:SetStartAlpha(R(40, 100))
					prt:SetEndAlpha(5)
					prt:SetStartLength(size * 8)
					prt:SetEndLength(size * 16)
					prt:SetStartSize(size * 2)
					prt:SetEndSize(size * 4)
					prt:SetAirResistance(100)
					prt:SetRoll(R(-5, 5))
					prt:SetLighting(true)
					prt:SetGravity(Vector(0, 0, 0))
					prt:SetColor(255, 255, 255, 255)
				end
	
				for i = 1, 100 do
					prt = emt:Add(ee.GetMaterial("smoke"), pos)
					prt:SetVelocity(VectorRand() * 60 * size)
					prt:SetDieTime(math.min((R(5, 10)*size) / 10, 15))
					prt:SetStartAlpha(R(40, 100))
					prt:SetEndAlpha(5)
					prt:SetStartSize(size * 8)
					prt:SetEndSize(size * 16)
					prt:SetAirResistance(100)
					prt:SetRoll(R(-5, 5))
					prt:SetLighting(true)
					prt:SetGravity(Vector(0, 0, size))
					prt:SetColor(255, 255, 255, 255)
				end
			end

			function ee.EmitHealthSmoke(pos, size, cur_hp, max_hp, vel)
				size = math.max(size, 10)
				
				emt:SetPos(pos)
				
				vel = vel * 0.25
				
				prt = emt:Add(ee.GetMaterial("smoke"), pos)
				prt:SetVelocity(vel + (VectorRand() * size))
				prt:SetDieTime(R(5, 10))
				prt:SetStartAlpha(math.abs((cur_hp / (max_hp / 4)) * 255 - 255))
				prt:SetEndAlpha(0)
				prt:SetStartSize(size * 2)
				prt:SetEndSize(size * 4)
				prt:SetAirResistance(200)
				prt:SetRoll(R(-5, 5))
				prt:SetLighting(true)
			end
			
			function ee.EmitDeadEntity(ent)
				local min, max = ent:WorldSpaceAABB()
				local offset = Vector(R(min.x, max.x), R(min.y, max.y), R(min.z, max.z)) 
				local normal = (offset - ent:GetPos()):GetNormalized()
				local size = math.Clamp((ent:BoundingRadius() + R(0, 20)) * ent.dt.size_mult, 5, 1000)
				
				local vel = ent:GetVelocity()
				
				local radius = ent:BoundingRadius()
				local max = math.floor(math.min(1 + vel:Length()/20/radius, 10))
				
				emt:SetPos(offset)
				
				for i = max, 0, -1 do
					i = (i / max) * 0.1
				
					local offset = offset - (vel * i)
				
					prt = emt:Add(ee.GetMaterial("fire"), offset)
					prt:SetVelocity((normal * 1000 * ent.dt.size_mult) - vel)
					prt:SetAirResistance(1000)
					prt:SetDieTime(0.5)
					prt:SetStartAlpha(255)
					prt:SetEndAlpha(1)
					prt:SetStartSize(size * R(0.75,1))
					prt:SetEndSize(size * 2)
					prt:SetRoll(R(-5, 5))
					local r = math.Rand(200, 255)
					prt:SetColor(255, r, r)
					--prt:SetLighting(true)

					prt = emt:Add(ee.GetMaterial("smoke"), offset - vel * 0.1)
					prt:SetVelocity(normal * R(10, 20))
					prt:SetStartAlpha(255)
					prt:SetStartSize(size)
					prt:SetEndSize(size * R(4,8))
					prt:SetRoll(R(-5, 5))
					
					if math.random() > 0.75 then
						local r,g,b = HSVToColor(R(0, 20), R(0.5, 0.75), 1)
						prt:SetColor(r,g,b)
						prt:SetDieTime(R(1, 2))
					else
						local r = R(230, 255)
						prt:SetColor(r,r,r)
						prt:SetDieTime(R(5, 20))
					end
					prt:SetLighting(true)
				end
			end
		end
		
		ee.SmokingEntities = {}
		
		function ee.SmokeThink()
			for key, ent in pairs(ee.SmokingEntities) do
				if ent:IsValid() then
					if (ent.last_emit or 0) < RealTime() then
						local vel = ent:GetVelocity()
						
						local radius = ent:BoundingRadius()
						local max = math.floor(math.min(1 + vel:Length()/5/radius, 10))
						
						for i = max, 0, -1 do
							i = (i / max) * 0.1
							ee.EmitHealthSmoke(ent:GetPos() - (vel * i), radius, ent:GetNWInt("ee_health"), ent.ee_max_hp or ent:BoundingRadius(), vel)	
						end
						
						ent.last_emit = RealTime() + 0.05
					end
				else
					ee.SmokingEntities[key] = nil
				end
			end
		end
		
		hook.Add("Think", "ee_smoke_think", ee.SmokeThink)
		
		function ee.AttachSmoke(ent, max)
			ent.ee_max_hp = max
			table.insert(ee.SmokingEntities, ent)
		end
		
		usermessage.Hook("ee_smoke", function(umr)
			local ent = umr:ReadEntity()
			local max = umr:ReadLong()
			
			if ent:IsValid() then
				ee.AttachSmoke(ent, max)
			end
		end)
		
		usermessage.Hook("ee_explosion", function(umr)
			local pos = umr:ReadVector()
			local size = umr:ReadFloat()
			
			ee.EmitExplosion(pos, size)
		end)
		
		usermessage.Hook("ee_explosion_sound", function(umr)
			local pos = umr:ReadVector()
			local size = umr:ReadFloat()
			
			sound.Play(
				"ambient/explosions/explode_" .. math.random(1,4) .. ".wav", 
				pos,
				100, 
				math.Clamp(-(size / 100) + 100 + math.Rand(-20, 20), 50, 255)
			)
		end)
	end
	
	if SERVER then
		local last = 0
		local count = 0
		
		function ee.EmitExplosion(pos, size)
			if last > CurTime() and count > 5 then return end
			
			umsg.Start("ee_explosion")
				umsg.Vector(pos)
				umsg.Float(size)
			umsg.End()
			
			ee.PlayExplosionSound(pos, size)
			
			last = CurTime() + 0.1
			count = count + 1
		end
		
		function ee.AttachSmoke(ent, max)
			umsg.Start("ee_smoke")
				umsg.Entity(ent)
				umsg.Long(max or ent.ee_max_hp)
			umsg.End()
		end
	end
	
	function ee.PlayExplosionSound(pos, size)
		umsg.Start("ee_explosion_sound")
			umsg.Vector(pos)
			umsg.Long(size)
		umsg.End()
	end
end

do -- debris entity
	local ENT = {}

	ENT.Type = "anim"
	ENT.Base = "base_anim"
	ENT.ClassName = "ee_debris_entity"
	
	function ENT:SetupDataTables()
		self:DTVar("Float", 0, "size_mult")
	end
	
	if CLIENT then
		function ENT:Think()
			if self:GetVelocity() ~= vector_origin and (self.last_emit or 0) < RealTime() then
				ee.EmitDeadEntity(self)
				self.last_emit = RealTime() + 0.05
			end
			self:NextThink(CurTime())
			return true
		end
	end
	
	if SERVER then
		function ENT:Initialize()
			self:PhysicsInit(SOLID_VPHYSICS)
			self:SetMoveType( MOVETYPE_VPHYSICS)   
			self:SetSolid(SOLID_VPHYSICS)
			self:SetColor(Color(0,0,0,255))
			local phys = self:GetPhysicsObject()
			
			if not phys:IsValid() then
				self:Explode()
				return
			end
			
			phys:EnableGravity(true)
			phys:EnableCollisions(true)
			phys:EnableDrag(false) 
			phys:Wake()

			self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS)
			
			self:Explode()
		end
		 
		function ENT:Explode()
			ee.EmitExplosion(self:GetPos(), self:BoundingRadius() * self.explosion_size_mult)
			
			--[[
			-- this effectivly too many entities being created during a frame. shaking is only an effect so only one shake entity is needed
			timer.Create("ee_shake", 0.25, 1, function()
				local ent = ents.Create("env_shake")
				ent:SetKeyValue("spawnflags", 4 + 8 + 16)
				
				ent:SetKeyValue("amplitude", 16)
				ent:SetKeyValue("frequency", 200.0)
				ent:SetKeyValue("duration", 2)
				ent:SetKeyValue("radius", self:BoundingRadius() * 5)
				
				ent:SetPos(self:GetPos())
				ent:Fire("StartShake", "", 0)
				ent:Fire("Kill", "", 4)
			end)
			]]
		end

		function ENT:PhysicsCollide(data, physobj)
			if self.dead then return end
			
			if not self.first then 
				self.first = true
			else
				self.dead = true
				self:Explode()
				timer.Simple(0.1, function() 
					if self:IsValid() then
						self:Remove() 
					end
				end)
			end
		end
	end
	
	scripted_ents.Register(ENT, ENT.ClassName, true)
	
	function ee.MakeDebris(old_ent)		
		if old_ent.ee_config.debris == 1 and old_ent:GetModel() then
			local ent = SERVER and ents.Create("ee_debris_entity")
			if ent and ent:IsValid() then
				ent:SetPos(old_ent:GetPos())
				ent:SetAngles(old_ent:GetAngles())
				ent:SetOwner(old_ent)
				ent:SetModel(old_ent:GetModel())
				
				ent.explosion_size_mult = old_ent.ee_config.explosion_size_mult
				ent.dt.size_mult = old_ent.ee_config.debris_size_mult
				
				ent:Spawn()
				
				
				local phys = ent:GetPhysicsObject()
				local radius = ent:BoundingRadius()
				phys:SetVelocity(Vector(radius * math.random(-30, 30), radius * math.random(-30, 30), radius * 10) * Vector( old_ent.ee_config.vel_mult, old_ent.ee_config.vel_mult, old_ent.ee_config.z_mult))
				phys:AddAngleVelocity(VectorRand() * radius * 2 * old_ent.ee_config.vel_mult)
			end
		else
			ee.EmitExplosion(old_ent:GetPos(), old_ent:BoundingRadius() * old_ent.ee_config.explosion_size_mult)
		end
		
		if old_ent.ee_config.blast_damage == 1 and not old_ent.ee_exploded then 
			local radius = old_ent:BoundingRadius() * 5
			old_ent.ee_exploded = true
			util.BlastDamage(old_ent, old_ent, old_ent:GetPos(), math.Clamp(radius * old_ent.ee_config.blast_damage_radius_mult, 0, 1500), radius * 2 * old_ent.ee_config.blast_damage_mult)
		end
	end
end

if SERVER then

	function ee.DamageEntity(ent, damage)
	
		if not ent.ee_config then
			ent.ee_config = table.Copy(ee.default_config)
		end
	
		-- vehicle hacks
		if ent:IsVehicle() and damage < 1 then 
			damage = damage * 10000 
		end
		
		damage = math.ceil(damage)
		
		ent.ee_max_hp = ent.ee_max_hp or ent:BoundingRadius() * (EE_HEALTH_MULTIPLIER or 15)
		ent.ee_cur_hp = (ent.ee_cur_hp or ent.ee_max_hp) - damage
		
		local fract = (ent.ee_cur_hp / ent.ee_max_hp)
		
		if fract < 0.25 then
			ee.AttachSmoke(ent)
		end
		
		if ent.ee_cur_hp <= 0 and not ent.ee_dead then
			timer.Simple(math.Rand(ent.ee_config.min_blast_delay, ent.ee_config.max_blast_delay), function()
				if ent:IsValid() and not ent.ee_dead then
					ee.MakeDebris(ent) 
					ent:Remove()
					ent.ee_dead = true
				end
			end)
		else
			ent.ee_color = ent.ee_color or {ColorToHSV((ent:GetColor()))}
			local col = HSVToColor(ent.ee_color[1], ent.ee_color[2], ent.ee_color[3] * fract)
			ent:SetColor(Color(col.r, col.g, col.b, 255))
		end
	end

	function ee.MakeExplosive(ent, health, config)
		ent.ee_active = true
		
		ent.ee_config = config or {}
		
		ent.ee_max_hp = health
		ent.ee_cur_hp = health
	end

	function ee.UnmakeExplosive(ent)
		ent.ee_active = nil
		ent.ee_max_hp = nil
		ent.ee_cur_hp = nil
	end

	hook.Add("EntityTakeDamage", "ee", function(ent, dmg)
		local owner = ent.CPPIGetOwner and ent:CPPIGetOwner() or NULL
		if ent.ee_active or (owner:IsValid() and owner:GetInfo("explosive_entities_global") == 1) then
			if not ent.ee_config and ee.config_vars and owner:IsValid() then
				local config = {}
				
				for key, val in pairs(ee.config_vars) do
					config[val] = owner:GetInfoNum("explosive_entities_" .. val, 1)
				end
				
				ent.ee_config = config
			end
			
			ee.DamageEntity(ent, dmg:GetDamage())
		end
	end)

end

do -- tool
	TOOL.Category = "Construction"
	TOOL.Name = "Explosive Entities"
	
	if CLIENT then
		language.Add("tool.explosive_entities.name", "Explosive Entities")
		language.Add("tool.explosive_entities.desc", "Will make props explode when damaged enough.")
		language.Add("tool.explosive_entities.0", "Left click on an prop to make it explosive. Right click on a contraption to make all the props explosive. Reload to clear explosives.")
		language.Add("undone_explosive_entities", "Undone explosive entity")
	end

	local ctrls = {}
	local vars = {}
	ee.config_vars = vars
	ee.default_config = {}
	
	local function ADD_VAR(key, def, lang, ctrl_type, ctrl_options)
		ctrl_options = ctrl_options or {}
		
		TOOL.ClientConVar[key] = def
		
		table.insert(vars, key)
		
		if CLIENT then
		--	RunConsoleCommand("explosive_entities_" .. key, def)
			language.Add("tool.explosive_entities." .. key, lang)
			ctrl_type = ctrl_type or "Checkbox"
			table.insert(ctrls, {ctrl_type, table.Merge({Label = "#tool.explosive_entities." .. key, Command = "explosive_entities_" .. key}, ctrl_options)})
		end
		
		ee.default_config[key] = def
	end

	ADD_VAR("health", -1, "Health (-1 = auto)", "Slider", {Type = "Integer", Min = -1, Max = 500})
	
	ADD_VAR("blast_damage", 1, "Enable blast damage")
	ADD_VAR("debris", 1, "Enable debris")
	
	ADD_VAR("sunbeams", 1, "Draw sunbeams (can be FPS intensive)")
	ADD_VAR("global", 0, "Enable globally on self (requires prop protection)")
	
	ADD_VAR("min_blast_delay", 0, "Minimum blast delay", "Slider", {Type = "Float", Min = 0, Max = 5}) 	
	ADD_VAR("max_blast_delay", 0.7, "Maximum blast delay", "Slider", {Type = "Float", Min = 0, Max = 5}) 	
	
	ADD_VAR("blast_damage_mult", 1, "Blast damage multiplier", "Slider", {Type = "Float", Min = 0, Max = 10}) 	
	ADD_VAR("blast_damage_radius_mult", 1, "Blast damage radius multiplier", "Slider", {Type = "Float", Min = 0, Max = 10}) 	
	
	ADD_VAR("health_mult", 1, "Health multiplier", "Slider", {Type = "Float", Min = 1, Max = 100})
	ADD_VAR("vel_mult", 1, "Debris velocity multiplier", "Slider", {Type = "Float", Min = 0, Max = 10})
	ADD_VAR("z_mult", 1, "Debris z velocity multiplier", "Slider", {Type = "Float", Min = 0, Max = 10}) 	
		
	ADD_VAR("explosion_size_mult", 1, "Explosion size multiplier", "Slider", {Type = "Float", Min = 0, Max = 5}) 	
	ADD_VAR("debris_size_mult", 1, "Debris size multiplier", "Slider", {Type = "Float", Min = 0, Max = 5}) 	
	

	
	function TOOL.BuildCPanel(pnl)
		for _, args in pairs(ctrls) do
			pnl:AddControl(unpack(args))
		end
	end

	function TOOL:MakeExplosive(trace, attached)
		if SERVER then
			if not trace.Entity:IsValid() or trace.Entity:IsPlayer() or trace.HitWorld or trace.Entity:IsNPC() then return end
		
			local entities = {trace.Entity}
			local health = self:GetClientNumber("health") * self:GetClientNumber("health_mult")
		
			if attached then
				for _, ent in pairs(constraint.GetAllConstrainedEntities(trace.Entity)) do
					table.insert(entities, ent)
				end
			end
			
			undo.Create("explosive_entities")
			undo.SetPlayer(self:GetOwner())
			undo.AddFunction(function() 
				local fuck=false
				for _, ent in pairs(entities) do 
					if IsValid(ent) then
						ee.UnmakeExplosive(ent)
						fuck=true
					end
				end 
				return fuck
			end)
			local undo_tbl = undo.GetTable()
			trace.Entity:CallOnRemove("explosive_entities", function() 
				undo.Do_Undo(undo_tbl)
			end)
			undo.Finish()
			
			for _, ent in pairs(entities) do				
				if self:GetClientNumber("health") == -1 then
					health = ent:BoundingRadius() * self:GetClientNumber("health_mult")
				end
				
				local config = {}
				
				for key, val in pairs(vars) do
					config[val] = self:GetClientNumber(val)
				end

				ee.MakeExplosive(ent, health, config)
				duplicator.StoreEntityModifier( ent, "explosive_entities", {health=health,config=config} )
			end
		end
		
		return true
	end
	
	function TOOL:LeftClick(trace)
		return self:MakeExplosive(trace, false)
	end

	function TOOL:RightClick(trace)
		return self:MakeExplosive(trace, true)
	end

	function TOOL:Reload(trace)
		if CLIENT then return true end
		
		if not trace.Entity:IsValid() or trace.Entity:IsPlayer() or trace.HitWorld or trace.Entity:IsNPC() then return end
		local entities=constraint.GetAllConstrainedEntities(trace.Entity)
		if self:GetOwner():KeyDown(IN_WALK) then entities={trace.Entity} end
		for _, ent in pairs(entities) do
			ee.UnmakeExplosive(ent)
			duplicator.ClearEntityModifier( ent, "explosive_entities" )
		end
		
		return true
	end	
	local dumbtrace = {
		FractionLeftSolid = 0,
		HitNonWorld       = true,
		Fraction          = 0,
		Entity            = NULL,
		HitPos            = Vector(0, 0, 0),
		HitNormal         = Vector(0, 0, 0),
		HitBox            = 0,
		Normal            = Vector(1, 0, 0),
		Hit               = true,
		HitGroup          = 0,
		MatType           = 0,
		StartPos          = Vector(0, 0, 0),
		PhysicsBone       = 0,
		WorldToLocal      = Vector(0, 0, 0),
	}
	local function dumbTrace(entity, pos)
		if entity then dumbtrace.Entity = entity end
		if pos then dumbtrace.HitPos = pos end
		return dumbtrace
	end
	duplicator.RegisterEntityModifier( "explosive_entities", function( ply, ent, data )
		local health,config=data.health,data.config
		local allow=hook.Run("CanTool",ply,dumbTrace(ent,ent:GetPos()),"explosive_entities")
		if allow then
			ee.MakeExplosive(ent, health, config)
		else
			ply:PrintMessage(3,"[Explosive Entities] Blocked by hook.")
		end
	end)
	saverestore.AddSaveHook( "explosive_entities", function( save )
		save:StartBlock("explosive_entities")
		local eeents={}
		for _,v in ipairs(ents.GetAll())do
			if v.ee_active then
				eeents[#eents+1]=v
			end
		end
		save:WriteInt(#eeents)
		for i=1,#eeents do
			local ent=eeents[i]
			local config=ent.ee_config
			local health=ent.ee_maxhp or ent.ee_curhp
			save:WriteEntity(ent)
			save:WriteTable({config,health},save)
		end
		save:EndBlock()
	end)
	local EntitiesToRestore={}
	saverestore.AddRestoreHook( "explosive_entities", function( restore )

		local name = restore:StartBlock()
		if ( name == "explosive_entities" ) then

			local l = restore:ReadInt()
			for i = 1, l do
				local ent = restore:ReadEntity()
				local savedata = saverestore.ReadTable( restore )
				if ( IsValidEntity( ent ) ) then
					EntitiesToRestore[ ent ] = savedata
				end
			end
		end
		restore:EndBlock()

	end )
	hook.Add( "Restored", "explosive_entities", function()
		for ent, savedata in pairs( EntitiesToRestore ) do
			local config,health=savedata[1],savedata[2]
			ee.MakeExplosive(ent,health,config)
			EntitiesToRestore[ ent ] = nil
		end
	end )
end 
print("Explosive Entities Loaded")