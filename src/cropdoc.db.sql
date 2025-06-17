BEGIN TRANSACTION;
CREATE TABLE IF NOT EXISTS "analysis_history" (
	"id"	INTEGER,
	"image_hash"	TEXT UNIQUE,
	"image_original_path"	TEXT,
	"image_size_bytes"	INTEGER,
	"image_dimensions"	TEXT,
	"image_capture_method"	TEXT CHECK("image_capture_method" IN ('Camera', 'Gallery')),
	"model_id"	INTEGER NOT NULL,
	"analysis_timestamp"	TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	"processing_time_ms"	INTEGER,
	"preprocessing_time_ms"	INTEGER,
	"inference_time_ms"	INTEGER,
	"top_prediction_disease_id"	INTEGER,
	"top_prediction_confidence"	REAL,
	"all_predictions"	TEXT,
	"user_feedback"	TEXT CHECK("user_feedback" IN ('Correct', 'Incorrect', 'Unsure', 'Partially Correct')),
	"user_corrected_disease_id"	INTEGER,
	"user_notes"	TEXT,
	"device_model"	TEXT,
	"android_version"	TEXT,
	"app_version"	TEXT,
	"location_region"	TEXT,
	"location_coordinates"	TEXT,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("model_id") REFERENCES "ml_models"("id"),
	FOREIGN KEY("top_prediction_disease_id") REFERENCES "diseases"("id"),
	FOREIGN KEY("user_corrected_disease_id") REFERENCES "diseases"("id")
);
CREATE TABLE IF NOT EXISTS "crops" (
	"id"	INTEGER,
	"name"	TEXT NOT NULL UNIQUE,
	"scientific_name"	TEXT,
	"description"	TEXT,
	"growing_season"	TEXT,
	"economic_importance"	TEXT,
	"cultivation_tips"	TEXT,
	"optimal_conditions"	TEXT,
	"created_at"	TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	"updated_at"	TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "diseases" (
	"id"	INTEGER,
	"crop_id"	INTEGER NOT NULL,
	"name"	TEXT NOT NULL,
	"scientific_name"	TEXT,
	"common_names"	TEXT,
	"severity_level"	TEXT CHECK("severity_level" IN ('Low', 'Medium', 'High', 'Critical')),
	"visual_symptoms"	TEXT NOT NULL,
	"physical_symptoms"	TEXT,
	"environmental_symptoms"	TEXT,
	"disease_stage_progression"	TEXT,
	"pathogen_type"	TEXT CHECK("pathogen_type" IN ('Fungal', 'Bacterial', 'Viral', 'Nutritional', 'Other')),
	"causative_agent"	TEXT,
	"transmission_method"	TEXT,
	"favorable_temperature_range"	TEXT,
	"favorable_humidity_range"	TEXT,
	"favorable_conditions"	TEXT,
	"seasonal_occurrence"	TEXT,
	"yield_loss_percentage_min"	REAL,
	"yield_loss_percentage_max"	REAL,
	"economic_impact_description"	TEXT,
	"affected_plant_parts"	TEXT,
	"occurrence_in_ghana"	TEXT CHECK("occurrence_in_ghana" IN ('Common', 'Occasional', 'Rare')),
	"regional_prevalence"	TEXT,
	"reference_images"	TEXT,
	"external_references"	TEXT,
	"created_at"	TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	"updated_at"	TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("crop_id") REFERENCES "crops"("id") ON DELETE CASCADE
);
CREATE TABLE IF NOT EXISTSAL TABLE diseases_fts USING fts5(
 name, visual_symptoms, causative_agent, 
content='diseases', content_rowid='id'
 );
CREATE TABLE IF NOT EXISTS "diseases_fts_config" (
	"k"	,
	"v"	,
	PRIMARY KEY("k")
) WITHOUT ROWID;
CREATE TABLE IF NOT EXISTS "diseases_fts_data" (
	"id"	INTEGER,
	"block"	BLOB,
	PRIMARY KEY("id")
);
CREATE TABLE IF NOT EXISTS "diseases_fts_docsize" (
	"id"	INTEGER,
	"sz"	BLOB,
	PRIMARY KEY("id")
);
CREATE TABLE IF NOT EXISTS "diseases_fts_idx" (
	"segid"	,
	"term"	,
	"pgno"	,
	PRIMARY KEY("segid","term")
) WITHOUT ROWID;
CREATE TABLE IF NOT EXISTS "localized_content" (
	"id"	INTEGER,
	"content_type"	TEXT CHECK("content_type" IN ('disease_name', 'treatment_name', 'symptom', 'instruction', 'prevention_method')),
	"reference_id"	INTEGER NOT NULL,
	"language_code"	TEXT NOT NULL,
	"localized_text"	TEXT NOT NULL,
	"created_at"	TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	UNIQUE("content_type","reference_id","language_code"),
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "ml_models" (
	"id"	INTEGER,
	"model_name"	TEXT NOT NULL,
	"model_version"	TEXT NOT NULL,
	"model_file_path"	TEXT NOT NULL,
	"accuracy_percentage"	REAL,
	"training_date"	TIMESTAMP,
	"total_classes"	INTEGER,
	"input_image_size"	TEXT,
	"model_size_mb"	REAL,
	"inference_time_ms"	INTEGER,
	"is_active"	BOOLEAN DEFAULT TRUE,
	"created_at"	TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "model_class_mappings" (
	"id"	INTEGER,
	"model_id"	INTEGER NOT NULL,
	"class_index"	INTEGER NOT NULL,
	"class_label"	TEXT NOT NULL,
	"disease_id"	INTEGER,
	"confidence_threshold"	REAL DEFAULT 0.65,
	PRIMARY KEY("id" AUTOINCREMENT),
	UNIQUE("model_id","class_index"),
	FOREIGN KEY("disease_id") REFERENCES "diseases"("id") ON DELETE SET NULL,
	FOREIGN KEY("model_id") REFERENCES "ml_models"("id") ON DELETE CASCADE
);
CREATE TABLE IF NOT EXISTS "prevention_methods" (
	"id"	INTEGER,
	"disease_id"	INTEGER NOT NULL,
	"prevention_category"	TEXT CHECK("prevention_category" IN ('Cultural', 'Biological', 'Chemical', 'Genetic')),
	"method_name"	TEXT NOT NULL,
	"description"	TEXT NOT NULL,
	"detailed_steps"	TEXT,
	"timing_description"	TEXT,
	"frequency"	TEXT,
	"seasonal_application"	TEXT,
	"crop_stage_application"	TEXT,
	"resources_needed"	TEXT,
	"skill_level_required"	TEXT CHECK("skill_level_required" IN ('Beginner', 'Intermediate', 'Advanced')),
	"labor_intensity"	TEXT CHECK("labor_intensity" IN ('Low', 'Medium', 'High')),
	"cost_level"	TEXT CHECK("cost_level" IN ('Very Low', 'Low', 'Medium', 'High', 'Very High')),
	"estimated_cost_ghs"	REAL,
	"accessibility_rural_areas"	TEXT CHECK("accessibility_rural_areas" IN ('Excellent', 'Good', 'Fair', 'Poor')),
	"effectiveness_rating"	INTEGER CHECK("effectiveness_rating" BETWEEN 1 AND 5),
	"scientific_evidence_level"	TEXT CHECK("scientific_evidence_level" IN ('Strong', 'Moderate', 'Limited', 'Anecdotal')),
	"compatible_with_other_methods"	TEXT,
	"integration_recommendations"	TEXT,
	"created_at"	TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("disease_id") REFERENCES "diseases"("id") ON DELETE CASCADE
);
CREATE TABLE IF NOT EXISTS "treatments" (
	"id"	INTEGER,
	"disease_id"	INTEGER NOT NULL,
	"treatment_category"	TEXT CHECK("treatment_category" IN ('Chemical', 'Biological', 'Cultural', 'Mechanical')),
	"treatment_type"	TEXT CHECK("treatment_type" IN ('Fungicide', 'Bactericide', 'Insecticide', 'Nematicide', 'Cultural Control', 'Biological Control')),
	"name"	TEXT NOT NULL,
	"active_ingredient"	TEXT,
	"product_examples"	TEXT,
	"description"	TEXT NOT NULL,
	"detailed_instructions"	TEXT,
	"application_method"	TEXT,
	"application_timing"	TEXT,
	"application_frequency"	TEXT,
	"dosage_rate"	TEXT,
	"dilution_ratio"	TEXT,
	"equipment_needed"	TEXT,
	"availability_status"	TEXT CHECK("availability_status" IN ('Readily Available', 'Commonly Available', 'Limited Availability', 'Rare')),
	"estimated_cost_ghs_min"	REAL,
	"estimated_cost_ghs_max"	REAL,
	"local_suppliers"	TEXT,
	"alternative_products"	TEXT,
	"effectiveness_rating"	INTEGER CHECK("effectiveness_rating" BETWEEN 1 AND 5),
	"safety_level"	TEXT CHECK("safety_level" IN ('Safe', 'Caution Required', 'Restricted Use', 'Prohibited')),
	"safety_precautions"	TEXT,
	"side_effects"	TEXT,
	"environmental_impact"	TEXT,
	"resistance_risk"	TEXT CHECK("resistance_risk" IN ('Low', 'Medium', 'High')),
	"rotation_compatibility"	TEXT,
	"organic_alternative"	BOOLEAN DEFAULT FALSE,
	"traditional_remedy"	BOOLEAN DEFAULT FALSE,
	"local_knowledge_source"	TEXT,
	"weather_restrictions"	TEXT,
	"soil_type_suitability"	TEXT,
	"crop_stage_restrictions"	TEXT,
	"created_at"	TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	"updated_at"	TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("disease_id") REFERENCES "diseases"("id") ON DELETE CASCADE
);
CREATE TABLE IF NOT EXISTSAL TABLE treatments_fts USING fts5(
 name, description, active_ingredient,
 content='treatments', content_rowid='id'
 );
CREATE TABLE IF NOT EXISTS "treatments_fts_config" (
	"k"	,
	"v"	,
	PRIMARY KEY("k")
) WITHOUT ROWID;
CREATE TABLE IF NOT EXISTS "treatments_fts_data" (
	"id"	INTEGER,
	"block"	BLOB,
	PRIMARY KEY("id")
);
CREATE TABLE IF NOT EXISTS "treatments_fts_docsize" (
	"id"	INTEGER,
	"sz"	BLOB,
	PRIMARY KEY("id")
);
CREATE TABLE IF NOT EXISTS "treatments_fts_idx" (
	"segid"	,
	"term"	,
	"pgno"	,
	PRIMARY KEY("segid","term")
) WITHOUT ROWID;
CREATE TABLE IF NOT EXISTS "usage_analytics" (
	"id"	INTEGER,
	"event_type"	TEXT NOT NULL,
	"event_data"	TEXT,
	"session_id"	TEXT,
	"timestamp"	TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "user_preferences" (
	"id"	INTEGER,
	"preference_key"	TEXT NOT NULL UNIQUE,
	"preference_value"	TEXT NOT NULL,
	"preference_type"	TEXT CHECK("preference_type" IN ('STRING', 'INTEGER', 'BOOLEAN', 'FLOAT', 'JSON')),
	"created_at"	TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	"updated_at"	TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY("id" AUTOINCREMENT)
);
INSERT INTO "crops" VALUES (1,'Cassava','Manihot esculenta','A resilient staple crop, providing a significant carbohydrate source and income.',NULL,'A cornerstone of Ghana''s agricultural sector, indispensable for national food security, nutritional well-being, and the economic livelihoods of millions of smallholder farmers.',NULL,NULL,'2025-06-05 16:16:42','2025-06-05 16:16:42');
INSERT INTO "crops" VALUES (2,'Maize','Zea mays','The most widely cultivated cereal, vital for both human consumption and animal feed.',NULL,'A cornerstone of Ghana''s agricultural sector, vital for food security and as a major source of feed for the livestock industry.',NULL,NULL,'2025-06-05 16:16:42','2025-06-05 16:16:42');
INSERT INTO "crops" VALUES (3,'Tomato','Solanum lycopersicum','A key vegetable, integral to Ghanaian cuisine and a major cash crop for many farmers.',NULL,'An essential crop for national food security and a significant source of income for smallholder farmers in Ghana.',NULL,NULL,'2025-06-05 16:16:42','2025-06-05 16:16:42');
INSERT INTO "diseases" VALUES (1,1,'Cassava Mosaic Disease',NULL,NULL,NULL,'Distinct mosaic pattern on leaves (light green/yellow patches), leaf distortion (curling, twisting), stunting of the plant, and reduced size and number of storage roots.',NULL,NULL,NULL,'Viral','Cassava mosaic geminiviruses (CMGs), primarily African Cassava Mosaic Virus (ACMV) and East African Cassava Mosaic Virus (EACMV)','Primarily through infected stem cuttings and secondary spread by the whitefly vector (Bemisia tabaci).',NULL,NULL,'Conditions favoring the whitefly vector, such as moderate temperatures and rainfall. Lower plant densities can also encourage faster spread.',NULL,12.0,90.0,'Recognized as the most significant biotic constraint to cassava production in sub-Saharan Africa. Causes substantial yield loss, reduces the quality of harvested roots, and threatens food security and income for farming households.','Leaves, Stems, Shoots, Roots','Common','Widespread across sub-Saharan Africa, including Ghana.',NULL,NULL,'2025-06-05 16:17:07','2025-06-05 16:17:07');
INSERT INTO "diseases" VALUES (2,2,'Northern Corn Leaf Blight',NULL,NULL,NULL,'Long (2.5-15 cm), elliptical, "cigar-shaped" tan or grayish-green lesions on leaves. Lesions are not restricted by veins and may have dark, sooty spores in the center.',NULL,NULL,NULL,'Fungal','Exserohilum turcicum (Setosphaeria turcica)','Spores are dispersed by wind and rain splash from infected maize residue left on the soil surface.',NULL,NULL,'Moderate temperatures (18-27°C), high humidity, and prolonged leaf wetness.',NULL,15.0,50.0,'A significant threat to maize production, causing substantial grain yield reduction. It also negatively impacts the quality and quantity of maize stover used for animal fodder.','Leaves','Common','Significant threat in Ghana and across Sub-Saharan Africa.',NULL,NULL,'2025-06-05 16:17:07','2025-06-05 16:17:07');
INSERT INTO "diseases" VALUES (3,2,'Southern Corn Leaf Blight',NULL,NULL,NULL,'Tan, elongated, rectangular lesions between leaf veins. Race T, historically significant, also caused lesions with chlorotic halos and could affect all plant parts.',NULL,NULL,NULL,'Fungal','Bipolaris maydis (Cochliobolus heterostrophus)','Spores are dispersed by wind or rain splash from infested maize residue.',NULL,NULL,'Warm temperatures (20-32°C) and high humidity.',NULL,10.0,40.0,'Capable of causing significant yield losses. The historic epidemic caused by Race T highlighted the risks of genetic uniformity in crops. Race O continues to be a concern.','Leaves (primarily Race O); Stems, Husks, Kernels (historically with Race T)','Occasional','Reported in Ghana and many maize-growing regions globally.',NULL,NULL,'2025-06-05 16:17:07','2025-06-05 16:17:07');
INSERT INTO "diseases" VALUES (4,2,'Gray Leaf Spot',NULL,NULL,NULL,'Long, narrow, rectangular, brown to gray lesions that are sharply delimited by leaf veins, giving a "blocky" appearance.',NULL,NULL,NULL,'Fungal','Cercospora zeae-maydis, Cercospora zeina','Spores are dispersed by wind and splashing rain from infested maize residue.',NULL,NULL,'Warm temperatures (24-30°C) and prolonged high humidity (>90%).',NULL,0.0,70.0,'Considered one of the most economically damaging foliar diseases of maize globally. Can cause severe yield losses and reduce fodder quality.','Leaves, Sheaths, Husks','Common','Widespread across maize-growing regions of Africa, including Ghana.',NULL,NULL,'2025-06-05 16:17:07','2025-06-05 16:17:07');
INSERT INTO "diseases" VALUES (5,3,'Tomato Late Blight',NULL,NULL,NULL,'Irregularly shaped, dark brown to purplish-black lesions on leaves, often with a white, downy mold on the underside. Dark lesions on stems. Large, firm, brownish-green blotches on fruits.',NULL,NULL,NULL,'Other','Phytophthora infestans','Airborne sporangia dispersed by wind and rain splash from infected tomato or potato plants and debris.',NULL,NULL,'Cool to mild temperatures (10-26°C) and high moisture levels (rain, dew, fog).',NULL,20.0,100.0,'One of the most destructive diseases of tomato, capable of causing rapid and complete crop loss. It impacts yield, fruit quality, and farmer income significantly.','Leaves, Stems, Fruits','Common','A significant threat to tomato production in Ghana, particularly during the main rainy season.',NULL,NULL,'2025-06-05 16:17:07','2025-06-05 16:17:07');
INSERT INTO "diseases_fts" VALUES ('Cassava Mosaic Disease','Distinct mosaic pattern on leaves (light green/yellow patches), leaf distortion (curling, twisting), stunting of the plant, and reduced size and number of storage roots.','Cassava mosaic geminiviruses (CMGs), primarily African Cassava Mosaic Virus (ACMV) and East African Cassava Mosaic Virus (EACMV)');
INSERT INTO "diseases_fts" VALUES ('Northern Corn Leaf Blight','Long (2.5-15 cm), elliptical, "cigar-shaped" tan or grayish-green lesions on leaves. Lesions are not restricted by veins and may have dark, sooty spores in the center.','Exserohilum turcicum (Setosphaeria turcica)');
INSERT INTO "diseases_fts" VALUES ('Southern Corn Leaf Blight','Tan, elongated, rectangular lesions between leaf veins. Race T, historically significant, also caused lesions with chlorotic halos and could affect all plant parts.','Bipolaris maydis (Cochliobolus heterostrophus)');
INSERT INTO "diseases_fts" VALUES ('Gray Leaf Spot','Long, narrow, rectangular, brown to gray lesions that are sharply delimited by leaf veins, giving a "blocky" appearance.','Cercospora zeae-maydis, Cercospora zeina');
INSERT INTO "diseases_fts" VALUES ('Tomato Late Blight','Irregularly shaped, dark brown to purplish-black lesions on leaves, often with a white, downy mold on the underside. Dark lesions on stems. Large, firm, brownish-green blotches on fruits.','Phytophthora infestans');
INSERT INTO "diseases_fts_config" VALUES ('version',4);
INSERT INTO "diseases_fts_data" VALUES (1,X'05117e20');
INSERT INTO "diseases_fts_data" VALUES (10,X'000000000101010001010101');
INSERT INTO "diseases_fts_data" VALUES (137438953473,X'00000618033031350206010105010132020601010301013502060101040101610406010111010601010e0203636d76010601020b0205666665637403060101150305726963616e01080102070902026c6c03060101160302736f030601010d02026e64010e0101130501020c0106010117010601011302097070656172616e63650406010113020272650206010112020601010a01076265747765656e0306010106020869706f6c61726973030601020202046c61636b050601010803046967687402020501020502020403046f636b79040601011204057463686573050601011d0204726f776e040601010501060101050603697368050601011b0201790206010115020601010d010763617373617661010c020102020809030475736564030601010e0205656e746572020601011f030872636f73706f72610408010202050208686c6f726f7469630306010111020469676172020601010802016d0206010106030267730106010205020b6f63686c696f626f6c757303060102040302726e0202030102030303756c640306010114020675726c696e67010601010d01046461726b020601011a0308010104130208656c696d69746564040601010c0206697365617365010204040574696e6374010601010205066f7274696f6e010601010c02046f776e79050601011001056561636d76010601021203027374010601020d02096c6c6970746963616c020601010703076f6e67617465640306010103020a787365726f68696c756d020601020201046669726d050601011a02057275697473050601011f010d67656d696e6976697275736573010601020402056976696e67040601011002037261790408020101070503697368020601010c030365656e0106010108010601010d030601011c010568616c6f730306010112030276650206010119020d657465726f7374726f706875730306010205020b6973746f726963616c6c79030601010b0102696e020601011d030766657374616e730506010203020a72726567756c61726c79050601010201056c617267650506010119030274650502030203656166010601010b01020401080401010701080301010e040376657301060101060106010110030601010b030573696f6e73020801010e0501080101050c010601010801080101090f020469676874010601010702036f6e670206010102020601010201036d6179020601011804036469730306010203010601020402036f6c640506010111030473616963011203010103010203080901066e6172726f77040601010302076f72746865726e02020203017402060101130205756d626572010601011701026f6601080101100a030374656e050601010c02016e0106010105010601010f030c01010a0a0709020172020601010b01057061727473030601011803057463686573010601010a04047465726e0106010104020b6879746f706874686f7261050601020202046c616e7401060101120206010117020872696d6172696c79010601020602077572706c69736805060101070104726163650306010109020a656374616e67756c61720306010104010601010403056475636564010601011403087374726963746564020601011402046f6f7473010601011a010c7365746f737068616572696102060102040205686170656402060101090306010103040472706c79040601010b020a69676e69666963616e74030601010c03027a65010601011502046f6f7479020601011b030675746865726e0302020205706f726573020601011c040174040204020474656d73050601011803056f7261676501060101190306756e74696e67010601010f010174030601010a0202616e020601010a0106010102020368617404060101090301650106010111010601011e030601011302016f0406010106010601010603046d61746f050202020675726369636102060102050702756d0206010203020777697374696e67010601010e0109756e64657273696465050601011401057665696e7302060101160106010108010601010f020469727573010801020a0901057768697465050601010f02036974680306010110020601010d010679656c6c6f77010601010901047a65616504060102030303696e610406010206040908080d0a0c0d090917100e0e0f0b0f0b0c100a0d110b0c100f0b0809120a0a0d110f0b0c0d0b0c09100e110b0c140c0b0a140c091412090e110c0719141e0b0f0a0f0a110d0c080c0a0a15080c0c0b12100f0e0b160c0f0b13110b11090b0b0c060b0c0d080e0a120d090d090e10160c0c0f0d0b');
INSERT INTO "diseases_fts_docsize" VALUES (1,X'031911');
INSERT INTO "diseases_fts_docsize" VALUES (2,X'041e04');
INSERT INTO "diseases_fts_docsize" VALUES (3,X'041704');
INSERT INTO "diseases_fts_docsize" VALUES (4,X'031205');
INSERT INTO "diseases_fts_docsize" VALUES (5,X'031e02');
INSERT INTO "diseases_fts_idx" VALUES (1,X'',2);
INSERT INTO "prevention_methods" VALUES (1,1,'Cultural','Sanitation (Roguing)','Promptly identify, uproot, and destroy infected cassava plants to reduce the in-field source of the virus.',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-06-05 16:17:13');
INSERT INTO "prevention_methods" VALUES (2,1,'Cultural','Use of Clean Planting Material','The single most effective measure. Use certified virus-free stem cuttings from reputable sources like MoFA or CSIR-CRI.',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-06-05 16:17:13');
INSERT INTO "prevention_methods" VALUES (3,1,'Genetic','Planting CMD-Resistant Varieties','The most effective and sustainable strategy. Use varieties developed by institutions like CSIR-CRI. Examples include ''Afisiafi'', ''Abasa Fitaa'', ''Tech Bankye'', and newer varieties like ''CRI-Amansan Bankye''.',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-06-05 16:17:13');
INSERT INTO "prevention_methods" VALUES (4,1,'Biological','Biological Control of Whiteflies','Encouraging natural enemies of whiteflies, such as ladybugs and parasitic wasps, to reduce vector populations.',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-06-05 16:17:13');
INSERT INTO "prevention_methods" VALUES (5,1,'Cultural','Field Location and Hygiene','Avoid planting new fields next to old, infected ones. Clean farm tools when moving between fields.',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-06-05 16:17:13');
INSERT INTO "prevention_methods" VALUES (6,2,'Cultural','Residue Management','Practices that reduce infected maize residue on the soil surface, such as tillage, can lower primary inoculum. This must be balanced with soil conservation goals.',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-06-05 16:17:23');
INSERT INTO "prevention_methods" VALUES (7,2,'Cultural','Crop Rotation','Rotate maize with non-host crops like legumes (cowpea, soybean) for at least 1-2 years to break the disease cycle.',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-06-05 16:17:23');
INSERT INTO "prevention_methods" VALUES (8,2,'Genetic','Planting Resistant/Tolerant Varieties','The most effective approach. Use maize varieties with resistance to NCLB, SCLB, and GLS. Examples include ''Aseda'', some Pannar and Seed Co hybrids.',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-06-05 16:17:23');
INSERT INTO "prevention_methods" VALUES (9,3,'Cultural','Residue Management','Burying or managing crop residue helps reduce the survival of the pathogen between seasons.',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-06-05 16:17:23');
INSERT INTO "prevention_methods" VALUES (10,3,'Cultural','Crop Rotation','Rotating with non-host crops is highly effective at reducing inoculum levels.',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-06-05 16:17:23');
INSERT INTO "prevention_methods" VALUES (11,3,'Genetic','Planting Resistant/Tolerant Varieties','Use modern hybrids that do not carry the T-cms cytoplasm and have tolerance to Race O of the pathogen.',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-06-05 16:17:23');
INSERT INTO "prevention_methods" VALUES (12,4,'Cultural','Residue Management','Since the pathogen overwinters in residue, tillage or other management practices can reduce disease pressure.',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-06-05 16:17:23');
INSERT INTO "prevention_methods" VALUES (13,4,'Cultural','Crop Rotation','An effective strategy to reduce pathogen buildup in the soil and residue.',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-06-05 16:17:23');
INSERT INTO "prevention_methods" VALUES (14,4,'Genetic','Planting Resistant/Tolerant Varieties','Key strategy for GLS management. Varieties with good resistance ratings should be prioritized, especially in no-till systems.',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-06-05 16:17:23');
INSERT INTO "prevention_methods" VALUES (15,5,'Cultural','Sanitation and Field Hygiene','Start with certified disease-free seeds/transplants. Remove and destroy volunteer tomato/potato plants and infected plant debris.',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-06-05 16:17:32');
INSERT INTO "prevention_methods" VALUES (16,5,'Cultural','Site Selection and Water Management','Choose well-drained fields with good air circulation. Avoid overhead irrigation; use drip or furrow irrigation if possible.',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-06-05 16:17:32');
INSERT INTO "prevention_methods" VALUES (17,5,'Cultural','Staking and Pruning','Stake or trellis plants to improve air circulation and keep foliage and fruit off the ground. Prune lower leaves.',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-06-05 16:17:32');
INSERT INTO "prevention_methods" VALUES (18,5,'Genetic','Planting Resistant Varieties','A highly desirable strategy. Use locally adapted, resistant varieties like ''CRI-Kopia'' and ''CRI-Kwabena Kwabena''.',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-06-05 16:17:32');
INSERT INTO "prevention_methods" VALUES (19,5,'Cultural','Crop Rotation','Practice rotation with non-solanaceous crops (e.g., maize, legumes) for at least 2-3 seasons.',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-06-05 16:17:32');
INSERT INTO "treatments" VALUES (1,1,'Chemical','Insecticide','Judicious Chemical Control of Whiteflies','Imidacloprid (example)',NULL,'Should be a last resort due to insecticide resistance and harm to beneficial insects. Use only products registered and recommended by MoFA/PPRSD for whitefly control in cassava.',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Strictly follow local recommendations and safety guidelines. Avoid broad-spectrum insecticides to conserve natural enemies.',NULL,NULL,NULL,NULL,0,0,NULL,NULL,NULL,NULL,'2025-06-05 16:17:18','2025-06-05 16:17:18');
INSERT INTO "treatments" VALUES (2,2,'Chemical','Fungicide','Fungicide Application for NCLB','Strobilurins, Triazoles',NULL,'Can be economically viable on high-value hybrids under high disease pressure. Timing is critical, usually applied around tasseling if symptoms are present.',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Limited use in smallholder systems due to cost. Farmers must consult MoFA extension officers for advice on registered and recommended products and application timing.',NULL,NULL,NULL,NULL,0,0,NULL,NULL,NULL,NULL,'2025-06-05 16:17:27','2025-06-05 16:17:27');
INSERT INTO "treatments" VALUES (3,3,'Chemical','Fungicide','Fungicide Application for SCLB','Strobilurins, Triazoles',NULL,'May be considered for susceptible hybrids under favorable conditions for the disease. Application should be preventative or at first sign of disease.',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Consult local agricultural extension for recommendations on registered products, as usage is not widespread among smallholders.',NULL,NULL,NULL,NULL,0,0,NULL,NULL,NULL,NULL,'2025-06-05 16:17:27','2025-06-05 16:17:27');
INSERT INTO "treatments" VALUES (4,4,'Chemical','Fungicide','Fungicide Application for GLS','Strobilurins, Triazoles',NULL,'Application can be effective if initiated when disease first appears, especially to protect upper leaves around the tasseling stage.',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Farmers must seek guidance from local MoFA/PPRSD officials for the latest advice on registered, safe, and economically viable products.',NULL,NULL,NULL,NULL,0,0,NULL,NULL,NULL,NULL,'2025-06-05 16:17:27','2025-06-05 16:17:27');
INSERT INTO "treatments" VALUES (5,5,'Chemical','Fungicide','Preventative Fungicide Spray Program','Mancozeb, Metalaxyl/Mefenoxam, Chlorothalonil',NULL,'Often necessary for late blight management. Applications are most effective when applied preventatively before symptoms appear, especially during high-risk weather.',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Crucial to alternate fungicides with different modes of action to manage resistance. Farmers must use products registered by the EPA and recommended by MoFA/PPRSD, and follow all safety precautions and pre-harvest intervals.',NULL,NULL,NULL,NULL,0,0,NULL,NULL,NULL,NULL,'2025-06-05 16:17:48','2025-06-05 16:17:48');
INSERT INTO "treatments_fts" VALUES ('Judicious Chemical Control of Whiteflies','Should be a last resort due to insecticide resistance and harm to beneficial insects. Use only products registered and recommended by MoFA/PPRSD for whitefly control in cassava.','Imidacloprid (example)');
INSERT INTO "treatments_fts" VALUES ('Fungicide Application for NCLB','Can be economically viable on high-value hybrids under high disease pressure. Timing is critical, usually applied around tasseling if symptoms are present.','Strobilurins, Triazoles');
INSERT INTO "treatments_fts" VALUES ('Fungicide Application for SCLB','May be considered for susceptible hybrids under favorable conditions for the disease. Application should be preventative or at first sign of disease.','Strobilurins, Triazoles');
INSERT INTO "treatments_fts" VALUES ('Fungicide Application for GLS','Application can be effective if initiated when disease first appears, especially to protect upper leaves around the tasseling stage.','Strobilurins, Triazoles');
INSERT INTO "treatments_fts" VALUES ('Preventative Fungicide Spray Program','Often necessary for late blight management. Applications are most effective when applied preventatively before symptoms appear, especially during high-risk weather.','Mancozeb, Metalaxyl/Mefenoxam, Chlorothalonil');
INSERT INTO "treatments_fts_config" VALUES ('version',4);
INSERT INTO "treatments_fts_data" VALUES (1,X'');
INSERT INTO "treatments_fts_data" VALUES (10,X'00000000000000');
CREATE INDEX IF NOT EXISTS "idx_diseases_crop_id" ON "diseases" (
	"crop_id"
);
CREATE INDEX IF NOT EXISTS "idx_diseases_pathogen" ON "diseases" (
	"pathogen_type"
);
CREATE INDEX IF NOT EXISTS "idx_diseases_severity" ON "diseases" (
	"severity_level"
);
CREATE INDEX IF NOT EXISTS "idx_history_disease" ON "analysis_history" (
	"top_prediction_disease_id"
);
CREATE INDEX IF NOT EXISTS "idx_history_timestamp" ON "analysis_history" (
	"analysis_timestamp"
);
CREATE INDEX IF NOT EXISTS "idx_localized_content_ref" ON "localized_content" (
	"content_type",
	"reference_id"
);
CREATE INDEX IF NOT EXISTS "idx_model_mappings_disease" ON "model_class_mappings" (
	"disease_id"
);
CREATE INDEX IF NOT EXISTS "idx_model_mappings_model" ON "model_class_mappings" (
	"model_id"
);
CREATE INDEX IF NOT EXISTS "idx_prevention_category" ON "prevention_methods" (
	"prevention_category"
);
CREATE INDEX IF NOT EXISTS "idx_prevention_disease_id" ON "prevention_methods" (
	"disease_id"
);
CREATE INDEX IF NOT EXISTS "idx_treatments_availability" ON "treatments" (
	"availability_status"
);
CREATE INDEX IF NOT EXISTS "idx_treatments_category" ON "treatments" (
	"treatment_category"
);
CREATE INDEX IF NOT EXISTS "idx_treatments_disease_id" ON "treatments" (
	"disease_id"
);
CREATE TRIGGER diseases_fts_delete AFTER DELETE ON diseases
 BEGIN
 DELETE FROM diseases_fts WHERE rowid = OLD.id;
 END;
CREATE TRIGGER diseases_fts_insert AFTER INSERT ON diseases
 BEGIN
 INSERT INTO diseases_fts(rowid, name, visual_symptoms, causative_agent)
 VALUES (NEW.id, NEW.name, NEW.visual_symptoms, NEW.causative_agent);
 END;
CREATE TRIGGER diseases_fts_update AFTER UPDATE ON diseases
 BEGIN
 DELETE FROM diseases_fts WHERE rowid = OLD.id;
 INSERT INTO diseases_fts(rowid, name, visual_symptoms, causative_agent)
 VALUES (NEW.id, NEW.name, NEW.visual_symptoms, NEW.causative_agent);
 END;
COMMIT;
