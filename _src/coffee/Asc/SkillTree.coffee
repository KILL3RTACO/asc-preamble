Util = require "../Common/Util.js"

class module.exports

  constructor: () ->
    @__skills = []

  getSkills: -> @__skills.slice 0
  addSkill: -(skill) ->
    Util.validateInstance "skill", SkillTree.Skill
    @__skills.push skill

SkillTree.Skill = class Skill

  constructor: (maximumRank = 1, rank = 0,  skillRequirement = {}, treeRequirement = 0) ->
    @__maximumRank if Number.isInteger(maximumRank) then maximumRank else 1
    @__skillRequirement = skillRequirement
    @__treeRequirement = if Number.isInteger(treeRequirement) then treeRequirement else 0
    @__rank = if Number.isInteger(rank) then rank else 0

  setRank: (rank) ->
    return if not Number.isInteger rank
    @__rank = Math.min Math.max(0, rank), @__maximumRank
  getRank: -> @__rank

  getTreeRequirement: -> @__treeRequirement
  getSkillRequirement: -> @__skillRequirement
