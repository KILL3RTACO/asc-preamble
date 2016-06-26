{Window, World} = require "../asc"

module.exports = help = {}

class Help

  constructor: (@__emblem, @__name, @__desc, @__perks) ->

  render: ->
    html = """
      <div class='preamble-help'>
        <div class='preamble-help-img'><img src='./img/emblem/#{@__emblem}-light.svg'/></div>
        <div class='preamble-help-definition'>
          <div class='preamble-help-name'>#{@__name}</div>
          <div class='preamble-help-desc'>#{@__desc}</div>
          <div class='preamble-help-perks'>
    """
    html += "<div class='preamble-help-perk #{if p.startsWith("+") then "plus" else if p.startsWith("-") then "negative" else ""}'>#{p}</div>" for p in @__perks
    html += """
          </div>
        </div>
      </div>
    """

class ClassificationHelp extends Window

  constructor: -> super

  createContents: ->
    @addCloseButton()
    @getContainer().append "<div class='preamble-help-header'>Classifications</div>"
    cHelp = []
    aurDesc = """
      Aurora are known for being extroverted and proud, a trait commonly protrayed through their use of swords in battle.
      During wartime, before the establishment and creation of the #{World.getChallengeTraditionNameHtml()}, Aurora were known
      for fighting on the front lines. Stronger and more experienced Aurora are known to bend light in such ways that makes themselves
      or other objects appear invisible.<br/><br/>

      An Aurora typically wears somewhat formal clothing: men usually wear slim dress pants with a tucked-in
      shirt, and a jacket on occasion; women tend to wear a long-sleeved blouse and a frilly or pleated skirt. As a style choice, they may
      sometimes wear a fedora or baret. The colors of Aurora clothing are traditionally white with light gray or black accents.
    """
    glmDesc = """
      Golems are the muslce of #{World.getName()}. During times of war, their enourmous strength was often utilized for the destruction or moving of large objects. Their strength
      allows them to easily carry heavy weaponry, such as miniguns or rocket launchers; though - due to their size - Golems seldom ever carry them around in public.
      In modern day, the can often be seen serving as a bouncer in nightclubs or parties, or even bodygaurds. Stronger Golems have been reported to be
      capable of incredible feats, such as uprooting or knocking over trees. This, however, has not been seen for many years.<br/><br/>

      Traditionally, Golems have worn tank-tops and any sort of shorts or pants, coupled with running shoes. The colors of their clothing have long been known to be
      green for the base and brown for accents.
    """
    slmDesc = """
      Salamanders are fiesty and hot-headed. During war times, they would fight alongside the Aurora with shotguns (they have also been seen with other forms of light rifles,
      however). Stronger and more expereinced Salamanders can ignite fires from their hands and have even been to known to be immune to lava.<br/><br/>

      Salamander clothing is quite plain: men and women wear pants and shirts. The colors they wear are representative of flames - red as a base with yellow and orange accents.
    """
    shdDesc = """
      Shadowborne are introverted and stealthy. During wartime, they acted as recon groups and assassins (in quite the contrast to the Aurora) using sniper rifles.
      Even today, Shadowborne don't socialize much with the other Classifications, often opting to be alone or in small groups. Experienced Shadowborne have been known
      to create shadow copies/clones of themselves or teleport small distances.<br/><br/>

      Contrary to the Aurora, Shadowborne wear more comfortable clothing. Slim or skinny jeans are typically worn (although women are known to wear the skinny
      variant more often than men) with a shirt and zip-up hoodie. Sneakers/trainers are a must for them. As a style choice, some Shadowborne choose to dye their hair
      in a dark shade of common colors, often changing the laces of their shoes to match. The colors of Shadowborne clothing are traditionally black with dark gray
      or white accents, with the occasional exception of the hair or shoelaces.
    """
    xraDesc = """
      The Xarya have long been known for their 'go with the flow' attitude. Even in times of war, they took orders well, especially if they had some sort of incentive.
      Typically, Xarya use automatic rifles as their weapon of choice, but they have also been seen using semi-automatic marksman rifles as well. Xarya have always been
      avid swimmers; even today they can be seen surfing or swimming in their free time. Stronger Xarya are known to freeze entire lakes at a single touch.<br/><br/>

      Xarya dress extremely comfortably, moreso than the Shadowborne. They are often seen wearing swimsuits in public settings (the more modest women will often wear a shirt and
      swim shorts instead of a full bikini), though in more formal settings shirts are a requirement. They are also seen with sandals, flip-flops, or even barefoot in public
      areas. Traditional colors of a Xarya are blue for the base with light blue or teal as accents. As a style choice, any swimwear may have inticate patterns. Some Xarya choose
      to make their own patterns to represent their personality or history.
    """
    zprDesc = """
      Zephyr are the more hyper of the bunch, it often gets them into trouble. They are as mischievious as some Shadowborne, but they can be quite rowdy. During times
      of war, they would often serve as scouts. Whereas the Shadowborne would serve as recon from afar, Zephyr would scout ahead to get a closer look, utilizing their
      running speed and the scope of their medium-ranged marksman rifle. Stronger Zephyr have been known to run fast enough to cross rivers and lakes without falling
      into the water. Not many have seen this today, however.<br/><br/>

      Running shoes are an obvious choice for a Zephyr. Even in colder weather, Zephyr will wear some type of shorts and short-sleeved shirt. Aside from the shorts, which could
      be made of jean-like material and may not necessarily follow color conventions, traditional Zephyr colors are all shades of yellow.
    """
    cHelp.push new Help("classification/aurora", "Aurora", aurDesc, ["+ Free point in Swordplay"])
    cHelp.push new Help(null, "Golem", glmDesc, ["+ Free point in Heavy Weaponry"])
    cHelp.push new Help(null, "Salamander", slmDesc, ["+ Free point in Light Weaponry"])
    cHelp.push new Help("classification/shadowborne", "Shadowborne", shdDesc, ["+ Free point in Marksman"])
    cHelp.push new Help(null, "Xarya", xraDesc, ["+ Free point in Light Weaponry "])
    cHelp.push new Help(null, "Zephyr", zprDesc, ["+ Free point in Light Weaponry "])

    @getContainer().append(h.render()) for h in cHelp

help.Classification = new ClassificationHelp()
