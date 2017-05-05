class CQ
  class StagesMonster < Sequel::Model(:stages_monsters)
    many_to_one :monster
    many_to_one :stage
  end
end
