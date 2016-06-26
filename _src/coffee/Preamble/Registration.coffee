Journey          = require "../journey"

{Player, Weapon, World} = require "../asc"

Preamble = require "../preamble"

NAME           = ""
CLASSIFICATION = null
KINGDOM        = null
GENDER         = null
WEAPON_TYPE    = null

weaponChosen = false

populate = (combo, ascEnum) ->
  values = ascEnum.values()
  combo.setItems(v.getName() for v in values)
  return combo

module.exports =

  done: (doneFn) ->
    wwt.util.validateFunction "doneFn", doneFn
    @__doneFn = doneFn

  start: ->
    {AI} = Preamble
    Journey.reset({map: true})
    Journey.getMainContent().append "
      <div id='PreambleRegBanner'>
        #{AI.IRIS.beginTransmissionHtml()}<br/><br/>
        Welcome, challenger, to the 36<sup>th</sup> <b>Celebration of Harmony</b>: <i>The Third Trial of Helix</i>.<br/><br/>

        My name is #{AI.IRIS.getNameHtml()}. I am the manager of this arena; my fellow AIs and I
        work together in ensuring the arena is as harsh of a environment as it is humane. This is the third (floor-based) Arena that Helix
        has attempted since their first rotation in the <b>Celebration of Harmony</b>. Helix has a strong reputation when it comes to technology, so
        be on the lookout for new weapons and monsters!<br/><br/>

        It is <i>highly possible</i> that you will encounter other challengers. Because this challenge is more akin to a race than a tournament, engaging in combat
        <b>is optional</b>. Remember - unsportman-like behavior (such as attacking a challenger after a battle or encounter has been resolved) will not be tolerated.
        Punishment can range anywhere between disqualification to being charged with an <b><i>Act of Injustice Towards Humanity</i></b>.<br/><br/>

        I have sent you the registration form to be allowed entrance into the arena. Please <i>double-check</i> all information before submitting.<br/><br/>
        #{AI.IRIS.endTransmissionHtml()}
      </div>
      <div style='margin: 1em 0; text-align: center; font-size: 16pt'>Registration Form</div>
    "
    regForm = new wwt.Composite(Journey.getMainContent(), "PreambleRegForm")

    NAME  = ""
    CLASSIFICATION = Player.ClassificationType.values()[0]
    GENDER = Player.Gender.values()[0]
    KINGDOM = World.Kingdom.values()[0]
    WEAPON_TYPE = CLASSIFICATION.getNormalWeaponTypes()[0]

    {RegistrationHelp} = Preamble

    makeHelpLabel = (id, text, win) ->
      new wwt.Label(new wwt.Composite(regForm, "#{id}Container"), id).addClass("preamble-registration-help").setText(text).$__element.click -> win.open()

    new wwt.Label(regForm, "nameLabel").setText("Name:")
    name = new wwt.Text(regForm, "name").setPlaceholder("Full Name")
    makeHelpLabel("classLabel", "Classification:", RegistrationHelp.Classification)
    classification = populate(new wwt.Combo(regForm, "classification"), Player.ClassificationType).setText(CLASSIFICATION.getName())
    new wwt.Label(regForm, "genderLabel").setText("Gender:")
    gender = populate(new wwt.Combo(regForm, "gender"), Player.Gender).setText(GENDER.getName())
    new wwt.Label(regForm, "kingdomLabel").setText("Hailing Kingdom:")
    kingdom = populate(new wwt.Combo(regForm, "kingdom"), World.Kingdom).setText(KINGDOM.getName())
    new wwt.Label(regForm, "weaponLabel").setText("Weapon of Choice:")
    weapon = populate(new wwt.Combo(regForm, "weapon"), Weapon.Type).setText(WEAPON_TYPE.getName())

    cancel = Journey.getButton(0, 0)
    submit = Journey.getButton(1, 0)

    name.addListener wwt.event.Modify, (event) ->
      INVALID_NAME = /[^0-9 \-A-z]/
      if INVALID_NAME.test event.value
        event.canceled = true
        return

      NAME = event.value
      submit.setEnabled(NAME isnt null and NAME.length > 0)

    classification.addListener wwt.event.Selection, (event) ->
      CLASSIFICATION = Player.ClassificationType.values()[event.index]
      if not weaponChosen
        weaponType = CLASSIFICATION.getNormalWeaponTypes()[0].getName()
        weapon.setText weaponType
        WEAPON_TYPE = weaponType
    gender.addListener wwt.event.Selection, (event) -> GENDER = Player.Gender.values()[event.index]
    kingdom.addListener wwt.event.Selection, (event) -> KINGDOM = World.Kingdom.values()[event.index]
    weapon.addListener wwt.event.Selection, (event) ->
      WEAPON_TYPE = Weapon.Type.values()[event.index]
      weaponChosen = true

    cancel.setEnabled().setText("Cancel").addListener wwt.event.Selection, -> Preamble.mainMenu()
    submit.setText("Submit").addListener wwt.event.Selection, => @enterArena()

  getName: -> NAME
  getClassification: -> CLASSIFICATION
  getKingdom: -> KINGDOM
  getGender: ->  GENDER
  getWeaponType: -> WEAPON_TYPE

  enterArena: ->
    Journey.reset()
    Journey.getMainContent().append """
      As per the rules of entering the Arena, you hand in all loose personal belongings, essentially everything except your clothing.
      Anything you have handed over is stored in a locker that you can open upon completing, forfeiting, or being disqualified from the challenge.<br/><br/>

      Upon entrance of the Arena, you will be given a {Placeholder: DEF_WEAPON_FROM_TYPE}<br/><br/>

      Do you wish to continue?
    """
    Journey.getButton(0, 0).setEnabled().setText("Enter").addListener wwt.event.Selection, => @__doneFn.call() if typeof @__doneFn is "function"
    Journey.getButton(1, 0).setEnabled().setText("Leave").addListener wwt.event.Selection, -> Preamble.mainMenu()
