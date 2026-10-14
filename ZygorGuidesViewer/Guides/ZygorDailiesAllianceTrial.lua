local ZygorGuidesViewer=ZygorGuidesViewer
if not ZygorGuidesViewer then return end
if UnitFactionGroup("player")~="Alliance" then return end
if ZygorGuidesViewer.AllianceDailiesInstalled then return end

ZygorGuidesViewer:RegisterGuide("Zygor's Alliance Dailies Guides\\Grizzly Hills\\Grizzly Hills Pre-Quests",[[
	author support@zygorguides.com
	description This guide section contains the pre-quests to unlock the daily quest in the Granite Springs region of Grizzly Hills.  The Blackriver Logging Camp, Blue Sky Logging Grounds, and Venture Bay regions of Grizzly Hills do not have any pre-quests to unlock the daily quests that are available in those regions.
// GRIZZLY HILLS PRE-QUESTS
	step //1
		goto Grizzly Hills,16.2,47.6
		.talk Samir##26424
		..accept Filling the Cages##11984
	step //2
		goto 16.4,48.3
		.talk Budd##26429
		..'Tell him it's time to play with the ice trolls|havebuff Budd's Attention Span|q 11984
	step //3
		goto 13.2,60.5
		.' Use Budd's pet bar skill Tag Troll to have him stun a troll|petaction Tag Troll
		.' Use your Bounty Hunter's Cage on the stunned troll|use Bounty Hunter's Cage##35736
		.' Capture a Live Ice Troll|q 11984/1
	step //4
		goto 16.2,47.6
		.talk Samir##26424
		..turnin Filling the Cages##11984
	step //5
		goto 16.4,47.8
		.talk Drakuru##26423
		..accept Truce?##11989
	step //6
		goto 16.5,47.8
		.' Click the Dull Carving Knife|tip It's a knife stuck in the side of this tree trunk.
		.collect 1 Dull Carving Knife##38083|q 11989
	step //7
		goto 16.4,47.8
		.' Use your Dull Carving Knife next to the yellow cage|use Dull Carving Knife##38083
		.talk Drakuru##26423
		..'Shake his hand
		..'Make a Blood Pact With Drakuru|goal Blood Pact With Drakuru|q 11989/1
	step //8
		goto 16.4,47.8
		.talk Drakuru##26423
		..turnin Truce?##11989
		..accept Vial of Visions##11990
	step //9
		goto 16,47.8
		.talk Ameenah##26474
		..buy 1 Imbued Vial|q 11990/1
	step //10
		goto 14.6,45.3
		.' Click the Hazewood Bushes|tip They look like small flower bushes on the ground around this area.
		.get 3 Haze Leaf|q 11990/2
	step //11
		goto 15.2,40.3
		.' Click a Waterweed|tip They look like big green bushes underwater around this area.
		.get Waterweed Frond|q 11990/3
	step //12
		goto 16.4,47.8
		.talk Drakuru##26423
		..turnin Vial of Visions##11990
	step //13
		goto 15.7,46.7
		.talk Prigmon##26519
		..accept Scourgekabob##12484
	step //14
		goto 15.7,46.9
		.' Click a Scourged Troll Mummy on the ground next to you
		.collect 1 Scourged Troll Mummy##38149|q 12484
	step //15
		goto 16.9,48.3
		.' Use your Scourged Troll Mummy next to the burning pile of mummies|use Scourged Troll Mummy##38149
		.' Burn a Mummified Carcass|goal Mummified Carcass Burned|q 12484/1
	step //16
		goto 16.7,48.3
		.talk Mack Fearsen##26604
		..turnin Scourgekabob##12484
		..accept Seared Scourge##12029
	step //17
		goto 16,29.9
		.' Jump on the big rock and stand on it
		.' Use Mack's Dark Grog and throw it at the trolls running around to the north|use Mack's Dark Grog##35908
		.' Burn 20 Scourge Trolls|goal 20 Scourge Trolls Burned |q 12029/1
	step 18
		goto 16.7,48.3
		.talk Mack Fearsen##26604
		..turnin Seared Scourge##12029
]])
ZygorGuidesViewer:RegisterGuide("Zygor's Alliance Dailies Guides\\Grizzly Hills\\Blackriver Logging Camp Dailies",[[
	author support@zygorguides.com
	description This guide section will walk you through completing the daily quest in the Blackriver Logging Camp region of Grizzly Hills.  There are no pre-quests needed to unlock the daily quest offered in this guide section.
	daily
// BLACKRIVER LOGGING CAMP
	step //1
		goto Grizzly Hills,30.0,59.8
		.talk Scout Captain Carter##27783
		..accept Blackriver Skirmish##12444
	step //2
		goto 28.3,63.4
		.' Kill Horde Players or Conquest Hold Raiders in the Blackriver Logging Camp
		.' Kill 10 Horde in Blackriver|goal 10 Horde in Blackriver slain|q 12444/1
	step //3
		goto 30.0,59.8
		.talk Scout Captain Carter##27783
		..turnin Blackriver Skirmish##12444
]])
ZygorGuidesViewer:RegisterGuide("Zygor's Alliance Dailies Guides\\Grizzly Hills\\Blue Sky Logging Grounds Dailies",[[
	author support@zygorguides.com
	description This guide section will walk you through completing the daily quests in the Blue Sky Logging Grounds region of Grizzly Hills.  There are no pre-quests needed to unlock the daily quests offered in this guide section.
	daily
// BLUE SKY LOGGING GROUNDS
	step //1
		goto Grizzly Hills,39.3,43.9
		.talk Sergeant Hartsman##27468
		..accept Kick 'Em While They're Down##12289|daily
	step //1
		goto 39.5,43.6
		.talk Synipus##27371
		..accept Shredder Repair##12244|daily
	step //1
		goto 39.6,43.4
		.talk Pipthwack##27416
		..accept Pieces Parts##12268|daily
	step //1
		goto 40.5,42.7
		.talk Rheanna##27484
		..accept Life or Death##12296|daily
	step //2
		goto 34.9,39.8
		.' Use Renewing Bandages on Wounded Wesfall Infantry|use Renewing Bandage##37576
		.' Heal 10 Westfall Infantry|goal 10 Westfall Infantry Healed|q 12296/1
		.' Click Grooved Cogs, Notched Sprockets, and High Tension Springs on the ground of the Blue Sky Logging Grounds
		..get 4 Grooved Cogs##37412|q 12268/1
		..get 3 Notched Sprockets##37413|q 12268/2
		..get 2 High Tension Springs##37416|q 12268/3
	step //2
		goto 33.4,35.7
		.' Kill Horde Players or Wounded Skirmishers in the area
		.' Eliminate 15 Horde units|goal 15 Horde units eliminated|q 12289/1
	step //2
		goto 34.9,39.8
		.' Find the Broken-down Shredder that spawns. Blizzards quest helper will mark it on your map for you.
		.' Click the Broken-down Shredder to get inside it
		.' Use your abilities on your hot bar to return the shredder to Synipus|goto Grizzly Hills,39.5,43.6
		.' Deliver 3 Shredders|goal 3 Shredder Delievered|q 12244/1
	step //3
		goto 39.3,43.9
		.talk Sergeant Hartsman##27468
		..turnin Kick 'Em While They're Down##12289
	step //3
		goto 39.5,43.6
		.talk Synipus##27371
		..turnin Shredder Repair##12244
	step //3
		goto 39.6,43.4
		.talk Pipthwack##27416
		..turnin Pieces Parts##12268
	step //3
		goto 40.5,42.7
		.talk Rheanna##27484
		..turnin Life or Death##12296
]])
ZygorGuidesViewer:RegisterGuide("Zygor's Alliance Dailies Guides\\Grizzly Hills\\Granite Springs Dailies",[[
	author support@zygorguides.com
	description This guide section will walk you through completing the daily quest in the Granite Springs region of Grizzly Hills.
	daily
// GRANITE SPRINGS
	step //1
		goto Grizzly Hills,16.7,48.3
		.talk Mack Fearsen##26604
		..accept Seared Scourge##12038
	step //234
		goto 16,29.9
		.' Jump on the big rock and stand on it
		.' Use Mack's Dark Grog and throw it at the trolls running around to the north|use Mack's Dark Grog##35908
		.' Burn 30 Scourge Trolls|goal 30 Scourge Trolls Burned |q 12038/1
	step //3
		goto Grizzly Hills,16.7,48.3
		.talk Mack Fearsen##26604
		..turnin Seared Scourge##12038
]])
ZygorGuidesViewer:RegisterGuide("Zygor's Alliance Dailies Guides\\Grizzly Hills\\Venture Bay Dailies",[[
	author support@zygorguides.com
	description This guide section will walk you through completing the daily quests in the Venture Bay region of Grizzly Hills.  There are no pre-quests needed to unlock the daily quests offered in this guide section.
	daily
// VENTURE BAY
	step //1
		goto Grizzly Hills,14.8,86.6
		.talk Commander Howser##27759
		..accept Riding the Red Rocket##12437
		.' If he's not there, then you have to take control of Venture Bay for the Alliance
		..' To take control of Venture Bay for the Alliance, go to 15.1,88.0|tip Hide behind the lighthouse in between the 2 big brown rocks. Flag yourself for PvP and a bar will appear under your minimap. Sit here until the bar marker is all the way to the left, this will make Commander Howser spawn.
	step //1
		goto 22.1,81.2
		.talk Sergeant Downey##27602
		..accept Smoke 'Em Out##12323
	step //1
		goto 22.1,81.2
		.talk Lieutenant Stuart##27562
		..accept Keep Them at Bay!##12316
	step //1
		goto 22.2,81.2
		.talk Baron Freeman##27520
		..accept Down With Captain Zorna##12314
	step //2
		goto 18.0,79.6
		.' Toss the Smoke Bomb into the buildings to smoke out Venture Co. Stragglers|use Smoke Bomb##37621
		.' Building one can be found at 18.0,79.6
		.' Building two can be found at 16.4,76.6
		.' Building three can be found at 14.6,76.7
		.' Smoke out 20 Venture Company Stragglers|goal 20 Venture Company Stragglers smoked out|q 12323/1
	step //2
		goto 19.9,76.4
		.' Kill Horde Players or Conquest Hold Berserker in Venture Bay
		.' Kill 10 Horde in Venture Bay|goal 10 Horde killed in Venture Bay|q 12316/1
	step //2
		goto 13.3,80.2
		..kill Captain Zorna##27511|q 12314/1
	step //2
		goto 16.4,80.3
		.' Click the Element 115 in the back room of the ship|tip It looks like a red canister with a handle on the top
		..collect Element 115##37664|q 12437
	step //3
		goto 9.6,79.2
		.' On the next step you will guide a rocket into this Horde Lumberboat
		.' Your target will be the wooden X on the back
		.' Go to 13.6,88.9|goto Grizzly Hills,13.6,88.9,0.5
		.' You will want to use your keys, not your mouse, to guide the rocket
		.' Avoid icebergs or the rocket will explode and you will have to start over
		.' Click a red rocket to take control of one|invehicle|c|q 12437
	step // 4
		goto 9.6,79.1
		.' Hit the wooden X on the back of the Horde Lumberboat
		.' Destroy the Horde Lumberboat|goal Horde Lumberboat destroyed|q 12437/1
	step //4
		goto 14.8,86.6
		.talk Commander Howser##27759
		..turnin Riding the Red Rocket##12437
	step //3
		goto 22.1,81.2
		.talk Lieutenant Stuart##27562
		..turnin Keep Them at Bay!##12316
	step //3
		goto 22.1,81.2
		.talk Baron Freeman##27520
		..turnin Down With Captain Zorna##12314
	step //3
		goto 22.1,81.2
		.talk Sergeant Downey##27602
		..turnin Smoke 'Em Out##12323
]])
ZygorGuidesViewer:RegisterGuide("Zygor's Alliance Dailies Guides\\Events\\Lunar Festival (February 14th - March 6th)\\Lunar Festival Main Questline",[[
	author support@zygorguides.com
	description This guide section will walk you through completing the main questline for the Lunar Festival event.
	step //
		goto Ironforge,30.9,61.6
		.talk Lunar Festival Emissary##15892
		..accept The Lunar Festival##8870
	step //
		goto Ironforge,28.8,16.2
		.talk Lunar Festival Harbinger##15895
		..turnin The Lunar Festival##8870
		..accept Lunar Fireworks##8867
	step //
		goto 29.9,14.2
		.talk Lunar Festival Vendor##15898
		..buy 8 Small Blue Rocket+
		..buy 2 Blue Rocket Cluster+
	step //
		goto 30.6,17.8
		.' Use Small Blue Rockets|use Small Blue Rocket##21558
		.' Use Blue Rocket Clusters|use Blue Rocket Cluster##21571
		.' Fire 8 Lunar Fireworks|q 8867/1
		.' Fire 2 Lunar Fireworks Clusters|q 8867/2
	step //
		goto 28.9,16.2
		.talk Lunar Festival Harbinger##15895
		..turnin Lunar Fireworks##8867
		..accept Valadar Starsong##8883
	step //
		goto 30.6,17.8
		.' Use the Lunar Festival Invitation while standing in the beam of light|use Lunar Festival Invitation##21711|q 8883
	step //
		goto Moonglade,53.6,35.3
		.talk Valadar Starsong##15864
		..turnin Valadar Starsong##8883
	step //
		goto Moonglade,36.4,59.9
		.' Use the Lunar Festival Invitation while standing in Ironforge Revelers beam of light|use Lunar Festival Invitation##21711|goto Ironforge|noway|c
]])
ZygorGuidesViewer:RegisterGuide("Zygor's Alliance Dailies Guides\\Events\\Lunar Festival (February 14th - March 6th)\\Lunar Festival Optimized Elders Path",[[
	author support@zygorguides.com
	description This guide section will walk you through an optimized path for honoring the elders that are spread out all over Azeroth for the Lunar Festival event.  The 13 elders that are inside instances are not included in this guide section.  Using this guide section, you will collect 62 of the total 75 Coins of Ancestry.
// EASTERN KINGDOMS
	step //
		.' The Lunar Festival event requires you to speak with special NPCs called Elders who will each give you a Coin of Ancestry. 
		These coins can be used to purchase special items from the Lunar Festival vendor. 
		The following section will take you on an optimized path for aquiring all 75 Coins of Ancestry.
		Since the coins are located all over Azeroth and Outland, this section assumes you possess all major flight paths to travel, this section will require a level 80 character for some steps. If you run into something you cannot do simply click the down arrow to progress to the next step.
	step //
		..'Fly to Chillwind Camp|goto Western Plaguelands,43.0,84.3,1.5|noway|c
	step //
		goto Western Plaguelands,69.0,73.0
		.talk Elder Moonstrike##15594
		..accept Moonstrike the Elder##8714|instant
	step //
		goto Western Plaguelands,66.0,47.8
		.talk Elder Meadowrun##15602
		..accept Meadowrun the Elder##8722|instant
	step //
		.' Follow the road west to Tirisfal Glades|goto Tirisfal Glades
	step //
		goto Tirisfal Glades,61.9,53.8
		.talk Elder Graveborn##15568
		..accept Graveborn the Elder##8652|instant
	step //
		goto Tirisfal Glades,66.7,38.1
		.talk Elder Darkcore##15564
		..accept Darkcore the Elder##8648|instant
	step //
		.' Go south west to Silverpine Forest|goto Silverpine Forest
	step //
		 goto Silverpine Forest,45.0,41.1
		.talk Elder Obsidian##15561
		..accept Obsidian the Elder##8645|instant
	step //
		.' Go north east to Tirisfal Glades|goto Tirisfal Glades
	step //
		'Go east to Western Plaguelands|goto Western Plaguelands|noway|c
	step //
		'Go to Chillwind Camp|goto Western Plaguelands,43.0,84.3,1.5|noway|c
	step //
		..'Fly to Light's Hope Chapel|goto Eastern Plaguelands,75.9,53.4|noway|c
	step //
		goto Eastern Plaguelands,75.7,54.6
		.talk Elder Snowcrown##15566
		..accept Snowcrown the Elder##8650|instant
	step //
		goto Eastern Plaguelands,35.6,68.8
		.talk Elder Windrun##15592
		..accept Windrun the Elder##8688|instant
	step //
		goto Eastern Plaguelands,75.8,53.4
		.talk Khaelyn Steelwing##12617
		..'Fly to Aerie Peak|goto The Hinterlands,13.4,46.5,4|noway|c
	step //
		goto The Hinterlands,49.9,47.9
		.talk Elder Highpeak
		.accept Highpeak the Elder##8643|instant
	step //
		 goto The Hinterlands,11.1,46.2
		 .talk Guthrum Thunderfist##8018
		..'Fly to Thelsamar|goto Loch Modan,33.9,50.8,0.5|noway|c
	step //
		goto Loch Modan,33.0,46.5
		.talk Elder Silvervein##15558
		..accept Silvervein the Elder##8642|instant
	step //
		 goto Loch Modan,33.9,51.0
		.talk Thorgrum Borrelson##1572
		..'Fly to Ironforge|goto Ironforge|noway|c
	step //
		goto Ironforge,28.1,17.0
		.talk Elder Bronzebeard##15871
		..accept Bronzebeard the Elder##8866|instant
	step //
		'Go outside to Dun Morogh|goto Dun Morogh|noway|c
	step //
		goto Dun Morogh,46.7,51.4
		.talk Elder Goldwell##15569
		..accept Goldwell the Elder##15569|instant
	step //
		'Go to Ironforge|goto Ironforge|noway|c
	step //
		goto Ironforge,55.5,47.7
		.talk Gryth Thurden##1573
		..'Fly to Thorium Point|goto Searing Gorge,35.9,27.7,3|noway|c
	step //
		goto Searing Gorge,21.1,78.8
		.talk Elder Ironband##15567
		..accept Ironband the Elder##8651|instant
	step //
		goto Searing Gorge,37.9,30.9
		.talk Lanie Reed##2941
		..'Fly to Morgan's Vigil|goto Burning Steppes,84.9,69.1,2|noway|c
	step //
		goto Burning Steppes,64.2,24.0
		.talk Elder Dawnstrider##15585
		..accept Dawnstrider the Elder##8683|instant
	step //
		goto Burning Steppes,81.9,46.3
		.talk Elder Rumblerock##15557
		..accept Rumblerock the Elder##8636|instant
	step//
		goto Burning Steppes,84.3,68.3
		.talk Borgus Stoutarm##2299
		..'Fly to Stormwind City|goto Stormwind City|noway|c
	step //
		goto Stormwind City,36.0,66.0
		.talk Elder Hammershout##15562
		..accept Hammershout the Elder##8646|instant
	step //
		.' Go outside of the city of Stormwind|goto Elwynn Forest|noway|c
	step //
		goto Elwynn Forest,39.6,63.5
		.talk Elder Stormbrow##15565
		..accept Stormbrow the Elder##8649|instant
	step //
		.' Go to Stormwind City|goto Stormwind City|noway|c
	step //
		..'Fly to Nethergarde Keep|goto Blasted Lands,65.4,19.2,9|noway|c
	step //
		goto Blasted Lands,57.7,54.7
		.talk Elder Bellowrage##15563
		..accept Bellowrage the Elder##8647|instant
	step //
		goto Blasted Lands,65.5,24.3
		.talk Alexandra Constantine##8609
		..'Fly to Sentinel Hill|goto Westfall,53.4,50.8,3|noway|c
	step //
		goto Westfall,55.6,47.0
		.talk Elder Skychaser##15577
		..accept Skychaser the Elder##8675|instant
	step //
		goto 56.5,52.6
		.talk Thor##523 
		..'Fly to the Rebel Camp|goto Stranglethorn Vale,38.2,4.1,0.5|noway|c
	step //
		goto Stranglethorn Vale,53.1,18.3
		.talk Elder Starglade##15596
		..accept Starglade the Elder##8716|instant
	step //
		goto Stranglethorn Vale,38.2,4.0
		.talk Nizzle##24366
		..'Fly to Booty Bay|goto Stranglethorn Vale,27.7,74.6,6|noway|c
	step //
		goto Stranglethorn Vale,26.3,76.4
		.talk Elder Winterhoof##15576
		..accept Winterhoof the Elder##15576|instant
	step //
		goto Stranglethorn Vale,26.3,76.4
		.talk Elder Winterhoof##15576
		..accept Winterhoof the Elder##15576|instant
	step //
		'Ride the boat to Ratchet|goto The Barrens|noway|c
// KALIMDOR
	step //
		goto The Barrens,62.6,36.7
		.talk Elder Windtotem##15582
		..accept Windtotem the Elder##8680 |instant
	step //
		'Go northeast to Durotar|goto Durotar|noway|c
	step //
		goto Durotar,53.1,43.5
		.talk Elder Runetotem##15572
		..accept Runetotem the Elder##8670 |instant
	step //
		'Go north to Orgrimmar|goto Orgrimmar|noway|c
	step //
		goto Orgrimmar,40.9,32.9
		.talk Elder Darkhorn##15579
		..accept Darkhorn the Elder##8677 |instant
	step //
		'Go southwest to The Barrens|goto The Barrens|noway|c
	step //
		goto The Barrens,51.4,30.6
		.talk Elder Moonwarden##15597
		..accept Moonwarden the Elder##8717 |instant
	step //
		goto The Barrens,45.0,57.9
		.talk Elder High Mountain##15588
		..accept High Mountain the Elder##8686 |instant
	step //
		'Go to west to Mulgore|goto Mulgore|noway|c
	step //
		goto Mulgore,48.3,53.4
		.talk Elder Bloodhoof##15575
		..accept Bloodhoof the Elder##8673 |instant
	step //
		'Go north to Thunder Bluff|goto Thunder Bluff|noway|c
	step //
		goto Thunder Bluff,72.2,23.5
		.talk Elder Ezra Wheathoof##15580
		..accept Wheathoof the Elder##8678 |instant
	step //
		'Go outside to Mulgore |goto Mulgore |noway |c
	step //
		'Go east to The Barrens|goto The Barrens|noway|c
	step //
		'Go south to Thousand Needles|goto Thousand Needles|noway|c
	step //
		goto Thousand Needles,45.3,49.8
		.talk Elder Skyseer##15584
		..accept Skyseer the Elder##8682 |instant
	step //
		goto Thousand Needles,79.0,76.9
		.talk Elder Morningdew##15604
		..accept Morningdew the Elder##8724 |instant
	step //
		'Go south to Tanaris|goto Tanaris |noway |c
	step //
		goto Tanaris,51.5,27.9
		.talk Elder Dreamseer##15586
		..accept Dreamseer the Elder##8684 |instant
	step //
		goto Tanaris,36.2,80.4
		.talk Elder Ragetotem##15573
		..accept Ragetotem the Elder##8671 |instant
	step //
		'Go northwest to Un'Goro Crater |goto Un'Goro Crater |noway |c
	step //
		goto Un'Goro Crater,50.4,76.2
		.talk Elder Thunderhorn##15583
		..accept Thunderhorn the Elder##8681 |instant
	step //
		goto 45.2,5.8
		.talk Gryfe##10583
		..' Fly to Cenarion Hold |goto Silithus,50.7,34.6,0.5 |noway |c
	step //
		goto Silithus,48.8,37.6
		.talk Elder Bladesing##15599
		..accept Bladesing the Elder##8719 |instant
	step //
		goto 23.1,11.8
		.talk Elder Primestone##15570
		..accept Primestone the Elder##8654 |instant
	step //
		goto 50.6,34.5
		.talk Cloud Skydancer##15177
		..' Fly to Feathermoon Stronghold |goto Feralas,30.3,43.3,0.5 |noway |c
	step //
		goto Feralas,59.5,40.0
		.talk Elder Mistwalker##15587
		..accept Mistwalker the Elder##8685 |instant	
	step //
		goto Feralas,76.7,37.7
		.talk Elder Grimtotem##15581
		..accept Grimtotem the Elder##8679 |instant	
	step //
		goto 89.5,45.9
		.talk Thyssiana##4319
		..' Fly to Talrendis Point |goto Azshara,11.9,77.5,0.5 |noway |c
	step //
		goto Azshara,72.4,84.9
		.talk Elder Skygleam##15600
		..accept Skygleam the Elder##8720 |instant
	step //
		goto 11.9,77.6
		.talk Jarrodenus##12577
		..' Fly to Everlook |goto Winterspring,62.3,36.7,0.5 |noway |c
	step //
		goto Winterspring,61.3,37.7
		.talk Elder Stonespire##15574
		..accept Stonespire the Elder##8672 |instant
	step //
		goto 55.6,43.6
		.talk Elder Brightspear##15606
		..accept Brightspear the Elder##8726 |instant
	step //
		goto 62.3,36.6
		.talk Maethrya##11138
		..' Fly to Emerald Sanctuary |goto Felwood,51.4,82.3,0.5 |noway |c
	step //
		goto Felwood,37.7,52.9
		.talk Elder Nightwind##15603
		..accept Nightwind the Elder##8723 |instant
	step //
		goto 51.5,82.2
		.talk Gorrim##22931
		..' Fly to Astranaar |goto Ashenvale,34.5,48.0,0.5 |noway |c
	step //
		goto Ashenvale,35.4,48.9
		.talk Elder Riversong##15605
		..accept Riversong the Elder##8725 |instant
	step //
		goto 34.4,48.0
		.talk Daelyshia##4267
		..' Fly to Auberdine |goto Darkshore,36.4,45.6,0.5 |noway |c
	step //
		goto Darkshore,36.7,46.6
		.talk Elder Starweave##15601
		..accept Starweave the Elder##8721 |instant
	step //
		goto 36.3,45.6
		.talk Caylais Moonfeather##3841
		..' Fly to Rut'theran Village |goto Teldrassil,58.4,93.9,0.5 |noway |c
	step //
		'Go into the pink portal to Darnassus |goto Darnassus |noway |c
	step //
		goto Darnassus,33.6,15.1
		.talk Elder Bladeswift##15598
		..accept Bladeswift the Elder##8718 |instant
	step //
		'Go outside the east exit of Darnassus to Teldrassil |goto Teldrassil |noway |c
	step //
		goto Teldrassil,57.2,60.7
		.talk Elder Bladeleaf##15595
		..accept Bladeleaf the Elder##8715 |instant
	step //
		'Go west to Darnassus |goto Darnassus |noway |c
	step //
		goto Darnassus,31.6,12.5
		.' Use the Lunar Festival Invitation while standing in the beam of light |use Lunar Festival Invitation##21711
		.' Go to Moonglade |goto Moonglade |c
	step //
		goto Moonglade,35.7,58.9
		.' Use the Lunar Festival Invitation while standing in the beam of light |use Lunar Festival Invitation##21711
		.' Go to Stormwind City |goto Stormwind City |c
// NORTHREND
	step //
		goto Stormwind City,18.1,25.5 |n
		.' Ride the boat to Borean Tundra |goto Borean Tundra |noway |c
	step //
		goto Borean Tundra,59.1,65.6
		.talk Elder Sardis##30348
		..accept Sardis the Elder##13012 |instant
	step //
		goto 57.4,43.7
		.talk Elder Arp##30364
		..accept Arp the Elder##13033 |instant
	step //
		goto 42.9,49.6
		.talk Elder Pamuya##30371
		..accept Pamuya the Elder##13029 |instant
	step //
		goto 33.8,34.4
		.talk Elder Northal##30360
		..accept Northal the Elder##13016 |instant
	step //
		'Go northeast to Sholazar Basin |goto Sholazar Basin |noway |c
	step //
		goto Sholazar Basin,49.8,63.6
		.talk Elder Sandrene##30362
		..accept Sandrene the Elder##13018 |instant
	step //
		goto 63.8,49.0
		.talk Elder Wanikaya##30365
		..accept Wanikaya the Elder##13024 |instant
	step //
		'Go southeast to Wintergrasp |goto Wintergrasp |noway |c
	step //
		goto Wintergrasp,50.5,16.4
		.' Click the Defender's Portal
		.' Go to the upper level of the Wintergrasp Fortress |goto Wintergrasp,50.4,15.9,0.1 |noway |c
	step //	
		goto 49.0,13.9
		.talk Elder Bluewolf##30368
		..accept Bluewolf the Elder##13026 |instant
	step //
		goto 49.6,15.9
		.' Click the Defender's Portal
		.' Go to outside of the Wintergrasp Fortress |goto Wintergrasp,49.6,16.3,0.1 |noway |c
	step //
		'Leave Wintergrasp and get back on your flying mount
		.' Skip to the next step of the guide once you are back on your flying mount
	step //
		'Go southeast to Dragonblight |goto Dragonblight |noway |c
	step //
		goto Dragonblight,35.1,48.3
		.talk Elder Skywarden##30373
		..accept Skywarden the Elder##13031 |instant
	step //
		goto 29.7,55.9
		.talk Elder Morthie##30358
		..accept Morthie the Elder##13014 |instant
	step //
		goto 48.8,78.2
		.talk Elder Thoim##30363
		..accept Thoim the Elder##13019 |instant
	step //
		'Go east to Grizzly Hills |goto Grizzly Hills |noway |c
	step //
		goto Grizzly Hills,64.2,47.0
		.talk Elder Whurain##30372
		..accept Whurain the Elder##13030 |instant
	step //
		goto 80.5,37.1
		.talk Elder Lunaro##30367
		..accept Lunaro the Elder##13025 |instant
	step //
		goto 60.6,27.7
		.talk Elder Beldak##30357
		..accept Beldak the Elder##13013 |instant
	step //
		'Go northwest to Zul'Drak |goto Zul'Drak |noway |c
	step //
		goto Zul'Drak,58.9,56.0
		.talk Elder Tauros##30369
		..accept Tauros the Elder##13027 |instant
	step //
		'Go northwest to The Storm Peaks |goto The Storm Peaks |noway |c
	step //
		goto The Storm Peaks,41.2,84.7
		.talk Elder Graymane##30370
		..accept Graymane the Elder##13028 |instant
	step //
		goto 28.9,73.7
		.talk Elder Fargal##30359
		..accept Fargal the Elder##13015 |instant
	step //
		goto 31.3,37.6
		.talk Elder Stonebeard##30375
		..accept Stonebeard the Elder##13020 |instant
	step //
		goto 64.6,51.3
		.talk Elder Muraco##30374
		..accept Muraco the Elder##13032 |instant
]])