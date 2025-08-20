use role accountadmin;
create role snowflake_intelligence_admin_rl;
grant snowflake_intelligence_admin_rl to role accountadmin;ALTER WAREHOUSE SNOWFLAKE_INTELLIGENCE_WH SET WAREHOUSE_SIZE = 'SMALL';
CREATE OR REPLACE WAREHOUSE SNOWFLAKE_INTELLIGENCE_WH 
WITH WAREHOUSE_SIZE = 'SMALL'
AUTO_SUSPEND = 120
AUTO_RESUME = TRUE;

GRANT USAGE ON WAREHOUSE SNOWFLAKE_INTELLIGENCE_WH TO ROLE SNOWFLAKE_INTELLIGENCE_ADMIN_RL;
use role snowflake_intelligence_admin_rl;
create or replace database data_on_draft;
grant all on database data_on_draft to role accountadmin;
grant all on schema public to role accountadmin;
use role accountadmin;
grant create network policy to role snowflake_intelligence_admin_rl;

-- Setup database and create table
USE DATABASE data_on_draft;
USE SCHEMA public;

-- Create table for Luce Line tap list
CREATE OR REPLACE TABLE LUCE_LINE_TAP_LIST (
    BEER_NAME VARCHAR(255),
    STYLE VARCHAR(255),
    ABV FLOAT,
    DESCRIPTION TEXT,
    BREWERY VARCHAR(255),
    BREWERY_CITY VARCHAR(100),
    BREWERY_STATE VARCHAR(50),
    SCRAPED_AT TIMESTAMP_NTZ,
    DESCRIPTION_EMBEDDING VECTOR(FLOAT, 768)
);

-- Create a reference table for beer comparison
create or replace table reference_beers (
  beer_name string,
  beer_abv float,
  beer_description string,
  beer_style string,
  brewery_name string,
  brewery_city string,
  brewery_state string
);

-- Insert 15 popular beers per style from Luce Line's tap list styles (or reasonable stand-ins)
insert into reference_beers (
  beer_name, beer_abv, beer_description, beer_style, brewery_name, brewery_city, brewery_state
) values

-- Hazy IPA
('Heady Topper', 8.0, 'Iconic unfiltered and intensely hop-forward double IPA with notes of citrus and tropical fruit.', 'Hazy IPA', 'The Alchemist', 'Stowe', 'VT'),
('Julius', 6.8, 'Soft and juicy New England IPA bursting with orange, mango, and peach aromas.', 'Hazy IPA', 'Tree House Brewing Company', 'Charlton', 'MA'),
('Hazy Little Thing', 6.7, 'Unfiltered, hop-saturated haze with ripe citrus and stone fruit notes.', 'Hazy IPA', 'Sierra Nevada Brewing Co.', 'Chico', 'CA'),
('Juicy Bits', 6.7, 'Pillowy NEIPA showcasing Citra, Mosaic, and El Dorado with orange and mango character.', 'Hazy IPA', 'WeldWerks Brewing Co.', 'Greeley', 'CO'),
('Cloud Candy', 6.5, 'Citra and Mosaic-driven haze with bright tropical and citrus flavors.', 'Hazy IPA', 'Mighty Squirrel Brewing Co.', 'Waltham', 'MA'),

-- West Coast IPA
('Pliny the Elder', 8.0, 'Classic West Coast double IPA with assertive bitterness and pine-citrus balance.', 'West Coast IPA', 'Russian River Brewing Company', 'Santa Rosa', 'CA'),
('Sculpin IPA', 7.0, 'Bright and bitter with notes of apricot, peach, mango, and lemon.', 'West Coast IPA', 'Ballast Point Brewing Company', 'San Diego', 'CA'),
('Stone IPA', 6.9, 'Piney, citrusy, and bitter—a quintessential West Coast IPA.', 'West Coast IPA', 'Stone Brewing', 'Escondido', 'CA'),
('Racer 5', 7.5, 'West Coast IPA with grapefruit, pine, and a dry, bitter finish.', 'West Coast IPA', 'Bear Republic Brewing Co.', 'Healdsburg', 'CA'),
('Lagunitas IPA', 6.2, 'Reliable classic with caramel malt backbone and resinous hop bite.', 'West Coast IPA', 'Lagunitas Brewing Company', 'Petaluma', 'CA'),

-- Double Dry Hopped Hazy IPA
('DDH Julius', 6.8, 'Extra-saturated citrus and tropical hop character from an additional dry hop.', 'Double Dry Hopped Hazy IPA', 'Tree House Brewing Company', 'Charlton', 'MA'),
('DDH Pseudo Sue', 5.8, 'Galaxy-driven juicy pale ale amped up with a second dry hop.', 'Double Dry Hopped Hazy IPA', 'Toppling Goliath Brewing Co.', 'Decorah', 'IA'),
('DDH Scaled', 7.0, 'Lush NEIPA with amplified aroma from an intensified dry hop.', 'Double Dry Hopped Hazy IPA', 'Trillium Brewing Company', 'Boston', 'MA'),
('DDH Green', 7.5, 'Hazy IPA with an additional dry hop for saturated dank and citrus notes.', 'Double Dry Hopped Hazy IPA', 'Tree House Brewing Company', 'Charlton', 'MA'),
('DDH King Sue', 7.8, 'Massive mosaic-driven DIPA with an extra dry hop for explosive tropical character.', 'Double Dry Hopped Hazy IPA', 'Toppling Goliath Brewing Co.', 'Decorah', 'IA'),

-- Double Dry Hopped West Coast IPA (some entries may be conceptual/limited variants)
('DDH Pliny the Elder', 8.0, 'Iconic West Coast DIPA intensified with an additional dry hop for extra aroma.', 'Double Dry Hopped West Coast IPA', 'Russian River Brewing Company', 'Santa Rosa', 'CA'),
('DDH Union Jack', 7.0, 'Crisp West Coast IPA brightened with a second dry hop for amplified pine and citrus.', 'Double Dry Hopped West Coast IPA', 'Firestone Walker Brewing Company', 'Paso Robles', 'CA'),
('DDH Swami''s', 6.8, 'Lean and bitter West Coast profile with boosted hop aromatics from double dry hopping.', 'Double Dry Hopped West Coast IPA', 'Pizza Port Brewing Company', 'Carlsbad', 'CA'),
('DDH West Coast IPA', 7.0, 'Classic resin and citrus-forward IPA with an extra dry hop charge.', 'Double Dry Hopped West Coast IPA', 'Green Flash Brewing Co.', 'San Diego', 'CA'),
('DDH Hopocalypse', 8.4, 'Dank and piney DIPA with layered dry hops for saturated aroma.', 'Double Dry Hopped West Coast IPA', 'Drake''s Brewing Company', 'San Leandro', 'CA'),

-- Cream Ale
('Genesee Cream Ale', 5.1, 'Smooth, crisp American cream ale with light hop bitterness.', 'Cream Ale', 'Genesee Brewing Company', 'Rochester', 'NY'),
('Little Kings Cream Ale', 5.5, 'Sweet-leaning, creamy ale with a clean finish.', 'Cream Ale', 'Hudepohl-Schoenling Brewing Co.', 'Cincinnati', 'OH'),
('Summer Solstice', 5.0, 'Creamy, slightly sweet ale with caramel and vanilla notes.', 'Cream Ale', 'Anderson Valley Brewing Company', 'Boonville', 'CA'),
('Spotted Cow', 4.8, 'Cream ale-inspired farmhouse beer—soft, smooth, and refreshing.', 'Cream Ale', 'New Glarus Brewing Company', 'New Glarus', 'WI'),
('Kiwanda Cream Ale', 5.4, 'Golden, easy-drinking cream ale with subtle floral hop character.', 'Cream Ale', 'Pelican Brewing Company', 'Pacific City', 'OR'),

-- Pilsner
('Pivo Pils', 5.3, 'Crisp, floral, and snappy German-style pilsner with classic hop bite.', 'Pilsner', 'Firestone Walker Brewing Company', 'Paso Robles', 'CA'),
('Prima Pils', 5.3, 'Bright herbal hop notes over a crackery malt base; crisp and bitter.', 'Pilsner', 'Victory Brewing Company', 'Downingtown', 'PA'),
('Slow Pour Pils', 4.7, 'Unfiltered German-style pils with a soft malt profile and firm bitterness.', 'Pilsner', 'Bierstadt Lagerhaus', 'Denver', 'CO'),
('Trumer Pils', 4.9, 'Delicate hop aroma, dry finish, and brilliant drinkability.', 'Pilsner', 'Trumer Brewery', 'Berkeley', 'CA'),
('Brooklyn Pilsner', 5.1, 'Refreshing pilsner with gentle floral hops and a clean finish.', 'Pilsner', 'Brooklyn Brewery', 'Brooklyn', 'NY'),

-- Unfiltered German Pils (Keller/Zwickel)
('Keller Pils', 4.9, 'Unfiltered German-style pilsner with a soft mouthfeel and grassy hops.', 'Unfiltered German Pils', 'Half Acre Beer Company', 'Chicago', 'IL'),
('Pilz', 4.7, 'Unfiltered German-style pils featuring noble hops and a crisp finish.', 'Unfiltered German Pils', 'Live Oak Brewing Company', 'Austin', 'TX'),
('Zwickel', 5.1, 'Unfiltered Bavarian-style lager with bready malt and floral hops.', 'Unfiltered German Pils', 'Urban Chestnut Brewing Company', 'St. Louis', 'MO'),
('Keller Pils', 5.2, 'Rustic, unfiltered pils with a balanced hop bite.', 'Unfiltered German Pils', 'Victory Brewing Company', 'Downingtown', 'PA'),
('Kellerbier', 5.0, 'Naturally cloudy lager with gentle bitterness and fresh malt character.', 'Unfiltered German Pils', 'Jack''s Abby Craft Lagers', 'Framingham', 'MA'),

-- Kolsch
('Fancy Lawnmower', 4.9, 'Crisp, delicately hopped Kölsch-style ale built for refreshment.', 'Kolsch', 'Saint Arnold Brewing Company', 'Houston', 'TX'),
('Rt. 113', 4.9, 'Classic Kölsch-style ale with a light malt profile and floral hops.', 'Kolsch', 'Sly Fox Brewing Company', 'Pottstown', 'PA'),
('Summertime Kölsch', 5.1, 'Light-bodied and refreshing with subtle citrus and floral notes.', 'Kolsch', 'Goose Island Beer Co.', 'Chicago', 'IL'),
('Kölsch', 4.7, 'Clean, crisp Kölsch-style ale with a soft malt backbone.', 'Kolsch', 'Occidental Brewing Co.', 'Portland', 'OR'),
('Kölsch', 4.8, 'Delicate, balanced Kölsch with gentle hop spice.', 'Kolsch', 'Altstadt Brewery', 'Fredericksburg', 'TX'),

-- Japanese Rice Lager
('Asahi Super Dry', 5.0, 'Crisp, ultra-dry lager brewed with rice for a clean finish.', 'Japanese Rice Lager', 'Asahi Breweries', 'Tokyo', 'Tokyo'),
('Sapporo Premium', 4.9, 'Dry, refreshing rice lager with light hop character.', 'Japanese Rice Lager', 'Sapporo Breweries', 'Sapporo', 'Hokkaido'),
('Kirin Ichiban', 5.0, 'Smooth and clean lager with a lightly sweet grain profile.', 'Japanese Rice Lager', 'Kirin Brewery Company', 'Yokohama', 'Kanagawa'),
('Extra Dry', 4.2, 'Sake-inspired rice lager with a bone-dry finish.', 'Japanese Rice Lager', 'Stillwater Artisanal', 'Baltimore', 'MD'),
('Hana Rice Lager', 4.8, 'Bright and crisp rice lager with subtle citrus aroma.', 'Japanese Rice Lager', 'Modern Times Beer', 'San Diego', 'CA'),

-- German Heffeweizen
('Weihenstephaner Hefeweissbier', 5.4, 'Classic Bavarian hefe with banana, clove, and silky wheat body.', 'German Heffeweizen', 'Bayerische Staatsbrauerei Weihenstephan', 'Freising', 'Bavaria'),
('Franziskaner Hefe-Weissbier', 5.0, 'Smooth and fruity wheat beer with signature banana and clove.', 'German Heffeweizen', 'Spaten-Franziskaner-Bräu', 'Munich', 'Bavaria'),
('Kellerweis', 4.8, 'Traditional hefeweizen with bright banana and clove notes.', 'German Heffeweizen', 'Sierra Nevada Brewing Co.', 'Chico', 'CA'),
('Live Oak HefeWeizen', 5.3, 'Authentic Bavarian-style hefe with expressive yeast character.', 'German Heffeweizen', 'Live Oak Brewing Company', 'Austin', 'TX'),
('Paulaner Hefe-Weißbier', 5.5, 'Smooth wheat beer with spice and ripe banana esters.', 'German Heffeweizen', 'Paulaner Brauerei', 'Munich', 'Bavaria'),

-- Sour
('SeaQuench Ale', 4.9, 'Tart mash-up of Kölsch, Gose, and Berliner Weisse with lime and sea salt.', 'Sour', 'Dogfish Head Craft Brewery', 'Milton', 'DE'),
('Le Terroir', 7.5, 'Dry-hopped American sour ale with tropical and citrus aromatics.', 'Sour', 'New Belgium Brewing Company', 'Fort Collins', 'CO'),
('Atrial Rubicite', 5.8, 'Barrel-aged sour ale refermented with raspberries.', 'Sour', 'Jester King Brewery', 'Austin', 'TX'),
('Sour In The Rye', 7.6, 'Complex, rye-based sour ale aged in oak with layered acidity.', 'Sour', 'The Bruery Terreux', 'Placentia', 'CA'),
('Kriek', 7.1, 'Northwest-style sour ale aged with cherries for bright fruit and tartness.', 'Sour', 'Cascade Brewing', 'Portland', 'OR'),

-- Smoothie Sour
('Slushy XL: Strawberry Banana', 5.3, 'Thick fruited smoothie sour loaded with strawberry and banana.', 'Smoothie Sour', '450 North Brewing Company', 'Columbus', 'IN'),
('Braaaaaaaains', 6.3, 'Lactose-tinged fruited sour with huge smoothie body and tropical fruit.', 'Smoothie Sour', 'Drekker Brewing Company', 'Fargo', 'ND'),
('Schmoojee: Mango', 6.5, 'Over-the-top fruited smoothie sour featuring lush mango.', 'Smoothie Sour', 'Imprint Beer Co.', 'Hatfield', 'PA'),
('Joose: Raspberry', 6.0, 'Rich, fruited smoothie sour bursting with raspberry.', 'Smoothie Sour', 'The Answer Brewpub', 'Richmond', 'VA'),
('Hill Cult', 6.0, 'Smoothie-style sour beer with intense fruit additions and soft acidity.', 'Smoothie Sour', 'Southern Grist Brewing Co.', 'Nashville', 'TN'),

-- Coffee Stout
('Breakfast Stout', 8.3, 'Coffee and chocolate-forward stout with a silky oatmeal base.', 'Coffee Stout', 'Founders Brewing Co.', 'Grand Rapids', 'MI'),
('Speedway Stout', 12.0, 'Imperial stout with espresso—rich, roasty, and decadent.', 'Coffee Stout', 'AleSmith Brewing Company', 'San Diego', 'CA'),
('Black House', 5.8, 'Coffee stout with a blend of house-roasted beans and cocoa.', 'Coffee Stout', 'Modern Times Beer', 'San Diego', 'CA'),
('Bomb!', 13.0, 'Imperial stout aged on coffee, cacao nibs, vanilla, and chiles.', 'Coffee Stout', 'Prairie Artisan Ales', 'Oklahoma City', 'OK'),
('Coffee Eugene', 6.8, 'Robust porter-leaning stout infused with coffee.', 'Coffee Stout', 'Revolution Brewing', 'Chicago', 'IL'),

-- Pale Ale
('Sierra Nevada Pale Ale', 5.6, 'Pine and grapefruit-forward classic American pale ale.', 'Pale Ale', 'Sierra Nevada Brewing Co.', 'Chico', 'CA'),
('Dale''s Pale Ale', 6.5, 'Bold, hoppy pale ale with a sturdy malt backbone.', 'Pale Ale', 'Oskar Blues Brewery', 'Longmont', 'CO'),
('Zombie Dust', 6.2, 'Citra-hopped pale ale with juicy citrus and resin.', 'Pale Ale', 'Three Floyds Brewing Co.', 'Munster', 'IN'),
('Mirror Pond Pale Ale', 5.0, 'Balanced pale ale highlighting Cascade hops.', 'Pale Ale', 'Deschutes Brewery', 'Bend', 'OR'),
('Daisy Cutter', 5.2, 'Aromatic pale ale with citrus, resin, and a crisp finish.', 'Pale Ale', 'Half Acre Beer Company', 'Chicago', 'IL'),

-- Hazy IPA (additional)
('Haze', 7.2, 'Juicy New England IPA with saturated citrus and tropical aromatics.', 'Hazy IPA', 'Tree House Brewing Company', 'Charlton', 'MA'),
('Green', 7.5, 'Lush and resinous hazy IPA with deep citrus and stone fruit character.', 'Hazy IPA', 'Tree House Brewing Company', 'Charlton', 'MA'),
('Congress Street', 7.2, 'Citra-forward NEIPA with orange rind, mango, and soft bitterness.', 'Hazy IPA', 'Trillium Brewing Company', 'Boston', 'MA'),
('Focal Banger', 7.0, 'NE-style IPA with bright citrus and pine from Citra and Mosaic.', 'Hazy IPA', 'The Alchemist', 'Stowe', 'VT'),
('All Citra Everything', 8.5, 'Single-hop DIPA dripping with juicy Citra character.', 'Hazy IPA', 'Other Half Brewing Co.', 'Brooklyn', 'NY'),
('Foggy Window', 8.2, 'Hazy DIPA with explosive tropical fruit and citrus aroma.', 'Hazy IPA', 'Monkish Brewing Co.', 'Torrance', 'CA'),
('Master Shredder', 5.5, 'Soft, crushable hazy pale with huge hop aroma.', 'Hazy IPA', 'The Veil Brewing Co.', 'Richmond', 'VA'),
('MC²', 8.0, 'Amped-up hazy IPA with ripe mango and orange zest.', 'Hazy IPA', 'Equilibrium Brewery', 'Middletown', 'NY'),
('Homestyle', 6.0, 'Oats and Mosaic-driven hazy pale with orange and melon.', 'Hazy IPA', 'Bearded Iris Brewing', 'Nashville', 'TN'),
('Juice Machine', 8.2, 'Hazy DIPA saturated with tropical fruit and citrus.', 'Hazy IPA', 'Tree House Brewing Company', 'Charlton', 'MA'),

-- West Coast IPA (additional)
('Blind Pig', 6.1, 'Crisp, bitter West Coast IPA with grapefruit and pine.', 'West Coast IPA', 'Russian River Brewing Company', 'Santa Rosa', 'CA'),
('Union Jack', 7.0, 'Classic West Coast profile with bright citrus and assertive bitterness.', 'West Coast IPA', 'Firestone Walker Brewing Company', 'Paso Robles', 'CA'),
('Duet', 7.0, 'Citrus and pine showcase in a lean, dry West Coast IPA.', 'West Coast IPA', 'Alpine Beer Company', 'Alpine', 'CA'),
('Hop Stoopid', 8.0, 'Resinous and dank with a firm, lingering bitterness.', 'West Coast IPA', 'Lagunitas Brewing Company', 'Petaluma', 'CA'),
('Enjoy By IPA', 9.4, 'Fresh hop-forward DIPA brewed not to last.', 'West Coast IPA', 'Stone Brewing', 'Escondido', 'CA'),
('Melvin IPA', 7.5, 'Bright tangerine, pine, and a snappy bitter finish.', 'West Coast IPA', 'Melvin Brewing', 'Alpine', 'WY'),
('Amalgamator', 7.1, 'Mosaic-forward West Coast IPA with citrus and tropical aromatics.', 'West Coast IPA', 'Beachwood Brewing', 'Long Beach', 'CA'),
('Breaking Bud', 6.5, 'Classic grapefruit and pine with a crisp, dry finish.', 'West Coast IPA', 'Knee Deep Brewing Co.', 'Auburn', 'CA'),
('The Pupil', 7.5, 'Lean and bitter San Diego-style IPA with tropical hop notes.', 'West Coast IPA', 'Societe Brewing Company', 'San Diego', 'CA'),
('Swami''s IPA', 6.8, 'Old-school West Coast IPA with citrusy bitterness.', 'West Coast IPA', 'Pizza Port Brewing Company', 'Carlsbad', 'CA'),

-- Double Dry Hopped Hazy IPA (additional)
('DDH Congress Street', 7.2, 'Extra dry-hopped Citra NEIPA with amplified orange and mango.', 'Double Dry Hopped Hazy IPA', 'Trillium Brewing Company', 'Boston', 'MA'),
('DDH Fort Point', 6.6, 'Double dry-hopped pale ale with saturated tropical aromatics.', 'Double Dry Hopped Hazy IPA', 'Trillium Brewing Company', 'Boston', 'MA'),
('DDH All Citra Everything', 8.5, 'DDH treatment adds intense citrus and tropical hop oils.', 'Double Dry Hopped Hazy IPA', 'Other Half Brewing Co.', 'Brooklyn', 'NY'),
('DDH Foggy Window', 8.2, 'Monkish DIPA with an extra dry hop for explosive aroma.', 'Double Dry Hopped Hazy IPA', 'Monkish Brewing Co.', 'Torrance', 'CA'),
('DDH MC²', 8.0, 'Equilibrium hazy DIPA with boosted hop saturation.', 'Double Dry Hopped Hazy IPA', 'Equilibrium Brewery', 'Middletown', 'NY'),
('DDH Master Shredder', 5.5, 'Soft pale ale supercharged with hop aroma.', 'Double Dry Hopped Hazy IPA', 'The Veil Brewing Co.', 'Richmond', 'VA'),
('DDH Ripe', 7.0, 'Extra dry-hopped hazy IPA with lush tropical fruit.', 'Double Dry Hopped Hazy IPA', 'Great Notion Brewing', 'Portland', 'OR'),
('DDH Logical Conclusion', 7.0, 'DDH treatment on a modern hazy IPA yields saturated aroma.', 'Double Dry Hopped Hazy IPA', 'Threes Brewing', 'Brooklyn', 'NY'),
('DDH Alien Church', 7.0, 'Oats and DDH amplify juicy citrus and pine.', 'Double Dry Hopped Hazy IPA', 'Tired Hands Brewing Company', 'Ardmore', 'PA'),
('DDH Juice Machine', 8.2, 'Overloaded with hop oils for maximal tropical expression.', 'Double Dry Hopped Hazy IPA', 'Tree House Brewing Company', 'Charlton', 'MA'),

-- Double Dry Hopped West Coast IPA (additional)
('DDH Blind Pig', 6.2, 'West Coast IPA with additional dry hop for elevated aroma.', 'Double Dry Hopped West Coast IPA', 'Russian River Brewing Company', 'Santa Rosa', 'CA'),
('DDH Hop Stoopid', 8.0, 'Extra dry hop layers dank resin and citrus.', 'Double Dry Hopped West Coast IPA', 'Lagunitas Brewing Company', 'Petaluma', 'CA'),
('DDH Amalgamator', 7.1, 'Mosaic-driven WCIPA with boosted hop saturation.', 'Double Dry Hopped West Coast IPA', 'Beachwood Brewing', 'Long Beach', 'CA'),
('DDH Orderville', 7.2, 'Modern West Coast IPA with an added dry hop for brightness.', 'Double Dry Hopped West Coast IPA', 'Modern Times Beer', 'San Diego', 'CA'),
('DDH The Pupil', 7.5, 'San Diego WCIPA amplified with an extra dry hop.', 'Double Dry Hopped West Coast IPA', 'Societe Brewing Company', 'San Diego', 'CA'),
('DDH West Coast IPA (Citra)', 7.0, 'Citra-forward WCIPA with layered DDH aroma.', 'Double Dry Hopped West Coast IPA', 'Green Flash Brewing Co.', 'San Diego', 'CA'),
('DDH Mai Tai P.A.', 6.5, 'Lean WC IPA with a double dry hop twist.', 'Double Dry Hopped West Coast IPA', 'Alvarado Street Brewery', 'Monterey', 'CA'),
('DDH Recursion IPA', 6.5, 'Crisp WCIPA with an intensified hop bouquet.', 'Double Dry Hopped West Coast IPA', 'Bottle Logic Brewing', 'Anaheim', 'CA'),
('DDH Scorpion Bowl', 7.5, 'Tropical-leaning WCIPA bumped with extra dry hop.', 'Double Dry Hopped West Coast IPA', 'Stone Brewing', 'Escondido', 'CA'),
('DDH Swell Rider', 7.0, 'West Coast IPA with a bright, citrus-forward DDH.', 'Double Dry Hopped West Coast IPA', 'Pizza Port Brewing Company', 'Carlsbad', 'CA'),

-- Cream Ale (additional)
('Sunlight Cream Ale', 5.3, 'Gold-medal American cream ale—clean, crisp, and refreshing.', 'Cream Ale', 'Sun King Brewing', 'Indianapolis', 'IN'),
('Grand Rabbits', 5.0, 'Sessionable cream ale with honeyed malt character.', 'Cream Ale', 'Blackrocks Brewery', 'Marquette', 'MI'),
('Sweet Action', 5.2, 'Silky hybrid cream ale with hop aroma and a smooth finish.', 'Cream Ale', 'Sixpoint Brewery', 'Brooklyn', 'NY'),
('Wexford Irish Cream Ale', 4.7, 'Nitro smooth Irish cream-style ale with a creamy head.', 'Cream Ale', 'Wexford', 'Dublin', 'Leinster'),
('Carolina Cream Ale', 4.5, 'Light-bodied cream ale brewed for maximum drinkability.', 'Cream Ale', 'Carolina Brewery', 'Chapel Hill', 'NC'),
('Cali Creamin''', 5.0, 'Vanilla cream ale with a soft, sweet finish.', 'Cream Ale', 'Mother Earth Brew Co.', 'Vista', 'CA'),
('St-Ambroise Cream Ale', 5.0, 'Canadian classic—smooth cream ale with balanced hops.', 'Cream Ale', 'McAuslan Brewing (St-Ambroise)', 'Montreal', 'QC'),
('Genesee Orange Cream Ale', 4.6, 'Orange-infused twist on the classic Genesee cream ale.', 'Cream Ale', 'Genesee Brewing Company', 'Rochester', 'NY'),
('Regular Coffee', 12.0, 'Imperial cream ale brewed with coffee and sweet milk.', 'Cream Ale', 'Carton Brewing Company', 'Atlantic Highlands', 'NJ'),
('Upstream Cream Ale', 4.8, 'Crisp Nashville-made cream ale with a gentle hop kiss.', 'Cream Ale', 'Little Harpeth Brewing', 'Nashville', 'TN'),

-- Pilsner (additional)
('Heater Allen Pils', 5.0, 'Czech-inspired craft pilsner with balanced bitterness.', 'Pilsner', 'Heater Allen Brewing', 'McMinnville', 'OR'),
('Notch Session Pils', 4.0, 'Crisp, low-ABV pilsner brewed for high drinkability.', 'Pilsner', 'Notch Brewing', 'Salem', 'MA'),
('Palatine Pils', 5.2, 'Delicate and floral German-style pils.', 'Pilsner', 'Suarez Family Brewery', 'Hudson', 'NY'),
('Mary', 4.8, 'Elegant German-style pilsner with soft hop spice.', 'Pilsner', 'Hill Farmstead Brewery', 'Greensboro Bend', 'VT'),
('Scrimshaw', 4.7, 'Dry, crisp pilsner with subtle floral hops.', 'Pilsner', 'North Coast Brewing Company', 'Fort Bragg', 'CA'),
('Bitburger Premium Pils', 4.8, 'Iconic German pilsner—clean, bitter, and refreshing.', 'Pilsner', 'Bitburger Brauerei', 'Bitburg', 'Rhineland-Palatinate'),
('Rothaus Pils Tannenzäpfle', 5.1, 'Highly aromatic German pils with a snappy finish.', 'Pilsner', 'Badische Staatsbrauerei Rothaus', 'Grafenhausen', 'Baden-Württemberg'),
('Jever Pilsener', 4.9, 'Northern German pilsner famed for its dry bitterness.', 'Pilsner', 'Friesisches Brauhaus zu Jever', 'Jever', 'Lower Saxony'),
('pFriem Pilsner', 5.0, 'Bright, herbal noble hop character with a crisp finish.', 'Pilsner', 'pFriem Family Brewers', 'Hood River', 'OR'),
('Post Shift Pils', 4.7, 'Czech-style pils brewed for post-shift refreshment.', 'Pilsner', 'Jack''s Abby Craft Lagers', 'Framingham', 'MA'),

-- Unfiltered German Pils (additional Keller/Zwickel)
('Ayinger Kellerbier', 5.3, 'Unfiltered amber lager with bready malt and gentle hops.', 'Unfiltered German Pils', 'Ayinger Privatbrauerei', 'Aying', 'Bavaria'),
('Hacker-Pschorr Kellerbier', 5.5, 'Naturtrüb lager with rustic malt and soft bitterness.', 'Unfiltered German Pils', 'Hacker-Pschorr Bräu', 'Munich', 'Bavaria'),
('St. GeorgenBräu Kellerbier', 4.9, 'Franconian kellerbier with a fresh-from-the-cellar taste.', 'Unfiltered German Pils', 'Privatbrauerei St. GeorgenBräu', 'Buttenheim', 'Bavaria'),
('Mahr''s Bräu Ungespundet Lager U', 5.2, 'Classic Franconian ungespundet kellerbier.', 'Unfiltered German Pils', 'Mahr''s Bräu', 'Bamberg', 'Bavaria'),
('Notch Zwickel', 4.5, 'Unfiltered lager with a soft grain profile and noble hops.', 'Unfiltered German Pils', 'Notch Brewing', 'Salem', 'MA'),
('Wayfinder Zwickel', 5.1, 'Keller-style lager with subtle haze and herbal hop notes.', 'Unfiltered German Pils', 'Wayfinder Beer', 'Portland', 'OR'),
('Kulmbacher Zwick''l', 5.3, 'Unfiltered lager from Kulmbach with balanced bitterness.', 'Unfiltered German Pils', 'Kulmbacher Brauerei', 'Kulmbach', 'Bavaria'),
('Paulaner Zwickl', 5.5, 'Naturtrüb lager with a soft malt body and spicy hops.', 'Unfiltered German Pils', 'Paulaner Brauerei', 'Munich', 'Bavaria'),
('Sünner Kellerbier', 4.9, 'Traditional kellerbier with a gentle hop profile.', 'Unfiltered German Pils', 'Brauerei Gebr. Sünner', 'Cologne', 'North Rhine-Westphalia'),
('Gänstaller Kellerpils', 5.2, 'Rustic unfiltered pils with grassy noble hop character.', 'Unfiltered German Pils', 'Gänstaller Bräu', 'Hallerndorf', 'Bavaria'),

-- Kolsch (additional)
('Reissdorf Kölsch', 4.8, 'Quintessential Cologne Kölsch—light, delicate, and refreshing.', 'Kolsch', 'Brauerei Heinrich Reissdorf', 'Cologne', 'North Rhine-Westphalia'),
('Früh Kölsch', 4.8, 'Classic Kölsch with a soft malt profile and floral hops.', 'Kolsch', 'Cölner Hofbräu Früh', 'Cologne', 'North Rhine-Westphalia'),
('Gaffel Kölsch', 4.8, 'Crisp, mildly bitter Kölsch from Cologne.', 'Kolsch', 'Privatbrauerei Gaffel Becker & Co.', 'Cologne', 'North Rhine-Westphalia'),
('Sion Kölsch', 4.8, 'Traditional Kölsch with a balanced, clean finish.', 'Kolsch', 'Sion Kölsch', 'Cologne', 'North Rhine-Westphalia'),
('Sünner Kölsch', 4.8, 'Bright, grainy-sweet Kölsch with gentle hop spice.', 'Kolsch', 'Brauerei Gebr. Sünner', 'Cologne', 'North Rhine-Westphalia'),
('Päffgen Kölsch', 4.8, 'Brewpub classic—fresh, delicate, and highly drinkable.', 'Kolsch', 'Privatbrauerei Päffgen', 'Cologne', 'North Rhine-Westphalia'),
('Schlafly Kölsch', 4.8, 'American take on Kölsch—clean and lightly floral.', 'Kolsch', 'The Saint Louis Brewery (Schlafly)', 'St. Louis', 'MO'),
('Alaskan Kölsch', 5.0, 'Crisp, malty Kölsch-style ale brewed in Alaska.', 'Kolsch', 'Alaskan Brewing Co.', 'Juneau', 'AK'),
('Krankshaft Kölsch', 5.0, 'Kölsch-style ale with a snappy finish.', 'Kolsch', 'Metropolitan Brewing', 'Chicago', 'IL'),
('Honey Kolsch', 5.2, 'Kölsch-style ale kissed with honey.', 'Kolsch', 'Rogue Ales', 'Newport', 'OR'),

-- Japanese Rice Lager (additional)
('Kirin Light', 3.2, 'Light, crisp rice lager with a dry finish.', 'Japanese Rice Lager', 'Kirin Brewery Company', 'Tokyo', 'Tokyo'),
('Sapporo Reserve', 5.2, 'Fuller-bodied rice lager with a smooth finish.', 'Japanese Rice Lager', 'Sapporo Breweries', 'Sapporo', 'Hokkaido'),
('Japanese Rice Lager', 4.8, 'Craft take on Japanese-style rice lager—clean and bright.', 'Japanese Rice Lager', 'Ecliptic Brewing', 'Portland', 'OR'),
('Rice & Shine', 4.5, 'Crisp lager brewed with rice for high drinkability.', 'Japanese Rice Lager', 'Westbrook Brewing Co.', 'Mt. Pleasant', 'SC'),
('Japanese Lager', 5.0, 'Rice-lager inspired by Japanese brewing tradition.', 'Japanese Rice Lager', 'Aslin Beer Co.', 'Alexandria', 'VA'),
('Rice Lager', 4.8, 'Bright and snappy rice lager with subtle citrus.', 'Japanese Rice Lager', 'Human Robot', 'Philadelphia', 'PA'),
('Rice Lager', 4.5, 'Simple, refreshing rice-based lager.', 'Japanese Rice Lager', 'Hudson Valley Brewery', 'Beacon', 'NY'),
('Rice Lager', 4.5, 'Crisp American craft rice lager.', 'Japanese Rice Lager', 'Brewery X', 'Anaheim', 'CA'),
('Rice Lager', 4.7, 'Light-bodied lager brewed with rice for a dry finish.', 'Japanese Rice Lager', 'Great Notion Brewing', 'Portland', 'OR'),
('Ichi-Go Ichi-E', 4.5, 'Japanese-inspired rice lager brewed for harmony and balance.', 'Japanese Rice Lager', 'Young Master', 'Hong Kong', 'Hong Kong'),

-- German Heffeweizen (additional)
('Ayinger Bräuweisse', 5.1, 'Classic Bavarian hefe with banana, clove, and soft wheat.', 'German Heffeweizen', 'Ayinger Privatbrauerei', 'Aying', 'Bavaria'),
('Schneider Weisse Original (TAP7)', 5.4, 'Traditional hefeweizen with expressive yeast character.', 'German Heffeweizen', 'Schneider Weisse G. Schneider & Sohn', 'Kelheim', 'Bavaria'),
('Erdinger Weissbier', 5.3, 'Smooth and refreshing wheat beer with subtle spice.', 'German Heffeweizen', 'Erdinger Weissbräu', 'Erding', 'Bavaria'),
('Hacker-Pschorr Weisse', 5.5, 'Banana-clove aromatics with a creamy wheat body.', 'German Heffeweizen', 'Hacker-Pschorr Bräu', 'Munich', 'Bavaria'),
('Hofbräu Hefe Weizen', 5.1, 'Bavarian hefe with bright banana esters and clove.', 'German Heffeweizen', 'Staatliches Hofbräuhaus', 'Munich', 'Bavaria'),
('Maisel''s Weisse Original', 5.2, 'Classic German wheat beer with spice and fruit.', 'German Heffeweizen', 'Brauerei Gebr. Maisel', 'Bayreuth', 'Bavaria'),
('Weihenstephaner Vitus', 7.7, 'Strong wheat bock with layered clove and banana.', 'German Heffeweizen', 'Bayerische Staatsbrauerei Weihenstephan', 'Freising', 'Bavaria'),
('Paulaner Hefe-Weißbier Dunkel', 5.3, 'Dark hefe with caramel and banana-clove notes.', 'German Heffeweizen', 'Paulaner Brauerei', 'Munich', 'Bavaria'),
('Schöfferhofer Hefeweizen', 5.0, 'Refreshing hefe with light citrus and spice.', 'German Heffeweizen', 'Schöfferhofer Weizenbier', 'Frankfurt', 'Hesse'),
('Widmer Hefe', 4.9, 'American-style hefe with a citrusy, soft profile.', 'German Heffeweizen', 'Widmer Brothers Brewing', 'Portland', 'OR'),

-- Sour (additional)
('Rodenbach Grand Cru', 6.0, 'Flanders red ale blending young and oak-aged beer for complex acidity.', 'Sour', 'Brouwerij Rodenbach', 'Roeselare', 'West Flanders'),
('Gueuze', 5.0, 'Traditional lambic blend with bright, complex acidity.', 'Sour', 'Brasserie Cantillon', 'Brussels', 'Brussels'),
('Supplication', 7.0, 'Brown ale aged in Pinot Noir barrels with cherries.', 'Sour', 'Russian River Brewing Company', 'Santa Rosa', 'CA'),
('Beatification', 5.5, 'Unblended sour aged in oak with vivid acidity.', 'Sour', 'Russian River Brewing Company', 'Santa Rosa', 'CA'),
('Tart of Darkness', 7.0, 'Sour stout aged in oak with a balanced tart roast.', 'Sour', 'The Bruery', 'Placentia', 'CA'),
('Surette Provision Saison', 6.2, 'Oak-aged mixed-culture farmhouse ale with bright acidity.', 'Sour', 'Crooked Stave Artisan Beer Project', 'Denver', 'CO'),
('Westbrook Gose', 4.0, 'Zesty, lightly salty gose with citrus notes.', 'Sour', 'Westbrook Brewing Co.', 'Mt. Pleasant', 'SC'),
('Leipziger Gose', 4.5, 'Traditional gose with coriander and salt.', 'Sour', 'Bayerischer Bahnhof', 'Leipzig', 'Saxony'),
('Blueberry Ale (Sour)', 7.1, 'Barrel-aged sour with blueberries for fruit-forward tartness.', 'Sour', 'Cascade Brewing', 'Portland', 'OR'),
('Oude Kriek', 6.0, 'Traditional cherry lambic with deep, complex acidity.', 'Sour', 'Brouwerij 3 Fonteinen', 'Beersel', 'Flemish Brabant'),

-- Smoothie Sour (additional)
('Slushy XL: Mango Pineapple', 5.3, 'Thick smoothie sour packed with mango and pineapple.', 'Smoothie Sour', '450 North Brewing Company', 'Columbus', 'IN'),
('Slushy XL: Rainbow', 5.3, 'Over-the-top fruited smoothie sour medley.', 'Smoothie Sour', '450 North Brewing Company', 'Columbus', 'IN'),
('Chonk: Strawberry', 6.6, 'Lactose-heavy smoothie sour with strawberry and vanilla.', 'Smoothie Sour', 'Drekker Brewing Company', 'Fargo', 'ND'),
('Hydra: Dragonfruit Mango', 7.0, 'Monstrously fruited smoothie sour with lush texture.', 'Smoothie Sour', 'Mortalis Brewing Company', 'Avon', 'NY'),
('Schmoojee: Blueberry', 6.5, 'Blueberry-loaded smoothie sour with a creamy body.', 'Smoothie Sour', 'Imprint Beer Co.', 'Hatfield', 'PA'),
('Out of Order: Blue Milk', 6.0, 'Playful, heavily fruited smoothie sour variant.', 'Smoothie Sour', 'RAR Brewing', 'Cambridge', 'MD'),
('The Gadget', 8.0, 'Intensely fruited sour with bold raspberry and blackberry.', 'Smoothie Sour', 'Urban Artifact', 'Cincinnati', 'OH'),
('Frooted Sour: Peach', 6.2, 'Smoothie-style fruited sour with ripe peach.', 'Smoothie Sour', 'Equilibrium Brewery', 'Middletown', 'NY'),
('Smoothie Style Sour: Kiwi Strawberry', 6.0, 'Smoothie sour packed with kiwi and strawberry.', 'Smoothie Sour', 'Untitled Art', 'Waunakee', 'WI'),
('Double Spindle: Pineapple Coconut', 6.8, 'Lactose-laced smoothie sour with tropical fruit.', 'Smoothie Sour', 'Great Notion Brewing', 'Portland', 'OR'),

-- Coffee Stout (additional)
('KBS (Kentucky Breakfast Stout)', 12.0, 'Barrel-aged imperial stout with coffee and chocolate.', 'Coffee Stout', 'Founders Brewing Co.', 'Grand Rapids', 'MI'),
('Beer Geek Breakfast', 7.5, 'Oatmeal stout brewed with coffee for rich roast and cocoa.', 'Coffee Stout', 'Mikkeller', 'Copenhagen', 'Denmark'),
('Even More Jesus (Coffee)', 12.0, 'Massive imperial stout variant with coffee.', 'Coffee Stout', 'Evil Twin Brewing', 'Brooklyn', 'NY'),
('Espresso Yeti', 9.5, 'Imperial stout with espresso—bold roast and chocolate.', 'Coffee Stout', 'Great Divide Brewing Co.', 'Denver', 'CO'),
('Night & Day', 9.0, 'Robust coffee stout with cacao and a velvety body.', 'Coffee Stout', 'Trillium Brewing Company', 'Boston', 'MA'),
('Coffee Dino S''mores', 10.5, 'Imperial stout with coffee, cocoa nibs, and vanilla.', 'Coffee Stout', 'Off Color Brewing', 'Chicago', 'IL'),
('Rise & Grind', 9.0, 'Imperial coffee stout with rich espresso character.', 'Coffee Stout', 'High Water Brewing', 'Lodi', 'CA'),
('Double Shot', 7.6, 'Coffee stout showcasing carefully selected beans.', 'Coffee Stout', 'Tree House Brewing Company', 'Charlton', 'MA'),
('Café Death', 14.8, 'Barrel-aged imperial stout with coffee.', 'Coffee Stout', 'Revolution Brewing', 'Chicago', 'IL'),
('Java Cask', 12.2, 'Barrel-aged coffee stout with deep roast complexity.', 'Coffee Stout', 'Victory Brewing Company', 'Downingtown', 'PA'),

-- Pale Ale (additional)
('Edward', 5.2, 'American pale ale with elegant hop expression and balance.', 'Pale Ale', 'Hill Farmstead Brewery', 'Greensboro Bend', 'VT'),
('Peeper Ale', 5.5, 'Crisp pale ale with citrus, pine, and a clean finish.', 'Pale Ale', 'Maine Beer Company', 'Freeport', 'ME'),
('Alpha King', 6.6, 'Robust pale ale loaded with citrus and pine.', 'Pale Ale', 'Three Floyds Brewing Co.', 'Munster', 'IN'),
('Grunion', 5.5, 'Tropical-leaning pale ale with citrus hop punch.', 'Pale Ale', 'Ballast Point Brewing Company', 'San Diego', 'CA'),
('HopHands', 5.5, 'Oats and American hops in a soft, aromatic pale ale.', 'Pale Ale', 'Tired Hands Brewing Company', 'Ardmore', 'PA'),
('Pale 31', 4.9, 'Delicate, balanced pale ale celebrating West Coast hops.', 'Pale Ale', 'Firestone Walker Brewing Company', 'Paso Robles', 'CA'),
('Guayabera', 5.5, 'Citra-hopped pale ale with orange and lime.', 'Pale Ale', 'Cigar City Brewing', 'Tampa', 'FL'),
('420 Extra Pale Ale', 5.7, 'Easy-drinking extra pale with bright hop character.', 'Pale Ale', 'SweetWater Brewing Company', 'Atlanta', 'GA'),
('Mosaic Promise', 5.5, 'Single-hop pale ale showcasing Mosaic.', 'Pale Ale', 'Founders Brewing Co.', 'Grand Rapids', 'MI'),
('5 Barrel Pale Ale', 5.2, 'Classic pale ale with citrus and floral notes.', 'Pale Ale', 'Odell Brewing Co.', 'Fort Collins', 'CO');

ALTER TABLE reference_beers ADD COLUMN description_embedding VECTOR(FLOAT, 768);

-- Generate the embeddings for all your reference beers
UPDATE reference_beers
SET description_embedding = SNOWFLAKE.CORTEX.EMBED_TEXT_768('snowflake-arctic-embed-m', "beer_style" || "beer_description");
