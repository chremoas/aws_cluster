CREATE TABLE alliances (
	alliance_id INT8 NOT NULL,
	alliance_name VARCHAR(100) NOT NULL,
	alliance_ticker VARCHAR(5) NOT NULL,
	inserted_dt TIMESTAMPTZ NOT NULL DEFAULT current_timestamp():::TIMESTAMPTZ,
	updated_dt TIMESTAMPTZ NOT NULL,
	CONSTRAINT "primary" PRIMARY KEY (alliance_id ASC),
	FAMILY "primary" (alliance_id, alliance_name, alliance_ticker, inserted_dt, updated_dt)
);

CREATE TABLE corporations (
	corporation_id INT8 NOT NULL,
	corporation_name VARCHAR(100) NOT NULL,
	alliance_id INT8 NULL,
	inserted_dt TIMESTAMPTZ NOT NULL DEFAULT current_timestamp():::TIMESTAMPTZ,
	updated_dt TIMESTAMPTZ NOT NULL,
	corporation_ticker VARCHAR(5) NOT NULL,
	CONSTRAINT "primary" PRIMARY KEY (corporation_id ASC),
	INDEX corporation_alliance_alliance_id_fk (alliance_id ASC),
	FAMILY "primary" (corporation_id, corporation_name, alliance_id, inserted_dt, updated_dt, corporation_ticker)
);

CREATE TABLE characters (
	character_id INT8 NOT NULL,
	character_name VARCHAR(100) NOT NULL,
	inserted_dt TIMESTAMPTZ NOT NULL DEFAULT current_timestamp():::TIMESTAMPTZ,
	updated_dt TIMESTAMPTZ NOT NULL,
	corporation_id INT8 NOT NULL,
	token VARCHAR(255) NOT NULL,
	CONSTRAINT "primary" PRIMARY KEY (character_id ASC),
	INDEX character_corporation_corporation_id_fk (corporation_id ASC),
	FAMILY "primary" (character_id, character_name, inserted_dt, updated_dt, corporation_id, token)
);

CREATE SEQUENCE roles_auto_inc MINVALUE 1 MAXVALUE 9223372036854775807 INCREMENT 1 START 18;

CREATE TABLE roles (
	role_name VARCHAR(70) NOT NULL,
	inserted_dt TIMESTAMPTZ NOT NULL DEFAULT current_timestamp():::TIMESTAMPTZ,
	updated_dt TIMESTAMPTZ NOT NULL,
	role_id INT8 NOT NULL DEFAULT nextval('roles_auto_inc':::STRING),
	chatservice_group VARCHAR(70) NULL,
	CONSTRAINT "primary" PRIMARY KEY (role_id ASC),
	UNIQUE INDEX role_role_name_uindex (role_name ASC),
	FAMILY "primary" (role_name, inserted_dt, updated_dt, role_id, chatservice_group)
);

CREATE TABLE alliance_character_leadership_role_map (
	alliance_id INT8 NOT NULL,
	character_id INT8 NOT NULL,
	role_id INT8 NOT NULL,
	CONSTRAINT "primary" PRIMARY KEY (alliance_id ASC, character_id ASC, role_id ASC),
	INDEX alliance_leadership__character_fk (character_id ASC),
	INDEX alliance_leadership__role_fk (role_id ASC),
	FAMILY "primary" (alliance_id, character_id, role_id)
);

CREATE TABLE alliance_corporation_role_map (
	alliance_id INT8 NOT NULL,
	corporation_id INT8 NOT NULL,
	role_id INT8 NOT NULL,
	CONSTRAINT "primary" PRIMARY KEY (alliance_id ASC, corporation_id ASC, role_id ASC),
	INDEX alliance_corporation_role_map__corporation_fk (corporation_id ASC),
	INDEX alliance_corporation_role_map__role_fk (role_id ASC),
	FAMILY "primary" (alliance_id, corporation_id, role_id)
);

CREATE TABLE alliance_role_map (
	role_id INT8 NOT NULL,
	alliance_id INT8 NOT NULL,
	CONSTRAINT "primary" PRIMARY KEY (role_id ASC, alliance_id ASC),
	INDEX alliance_role_map__alliance_fk (alliance_id ASC),
	FAMILY "primary" (role_id, alliance_id)
);

CREATE TABLE authentication_codes (
	character_id INT8 NOT NULL,
	authentication_code VARCHAR(20) NOT NULL,
	is_used BOOL NULL,
	CONSTRAINT "primary" PRIMARY KEY (character_id ASC),
	FAMILY "primary" (character_id, authentication_code, is_used)
);

CREATE SEQUENCE authentication_scopes_auto_inc MINVALUE 1 MAXVALUE 9223372036854775807 INCREMENT 1 START 1;

CREATE TABLE authentication_scopes (
	authentication_scope_id INT8 NOT NULL DEFAULT nextval('authentication_scopes_auto_inc':::STRING),
	authentication_scope_name VARCHAR(255) NOT NULL,
	CONSTRAINT "primary" PRIMARY KEY (authentication_scope_id ASC),
	FAMILY "primary" (authentication_scope_id, authentication_scope_name)
);

CREATE TABLE authentication_scope_character_map (
	character_id INT8 NOT NULL,
	authentication_scope_id INT8 NOT NULL,
	CONSTRAINT "primary" PRIMARY KEY (character_id ASC, authentication_scope_id ASC),
	INDEX scope_character_map__scope_fk (authentication_scope_id ASC),
	FAMILY "primary" (character_id, authentication_scope_id)
);

CREATE TABLE character_role_map (
	character_id INT8 NOT NULL,
	role_id INT8 NOT NULL,
	CONSTRAINT "primary" PRIMARY KEY (character_id ASC, role_id ASC),
	INDEX character_role_map__role_fk (role_id ASC),
	FAMILY "primary" (character_id, role_id)
);

CREATE TABLE corp_character_leadership_role_map (
	corporation_id INT8 NOT NULL,
	character_id INT8 NOT NULL,
	role_id INT8 NOT NULL,
	CONSTRAINT "primary" PRIMARY KEY (corporation_id ASC, character_id ASC, role_id ASC),
	INDEX leadership_role__character_fk (character_id ASC),
	INDEX leadership_role__role_fk (role_id ASC),
	FAMILY "primary" (corporation_id, character_id, role_id)
);

CREATE TABLE corporation_role_map (
	role_id INT8 NOT NULL,
	corporation_id INT8 NOT NULL,
	CONSTRAINT "primary" PRIMARY KEY (role_id ASC, corporation_id ASC),
	INDEX corporation_role_map__corporation_fk (corporation_id ASC),
	FAMILY "primary" (role_id, corporation_id)
);

CREATE SEQUENCE users_auto_inc MINVALUE 1 MAXVALUE 9223372036854775807 INCREMENT 1 START 237;

CREATE TABLE users (
	user_id INT8 NOT NULL DEFAULT nextval('users_auto_inc':::STRING),
	chat_id VARCHAR(255) NOT NULL,
	CONSTRAINT "primary" PRIMARY KEY (user_id ASC),
	FAMILY "primary" (user_id, chat_id)
);

CREATE TABLE user_character_map (
	user_id INT8 NOT NULL,
	character_id INT8 NOT NULL,
	CONSTRAINT "primary" PRIMARY KEY (user_id ASC, character_id ASC),
	INDEX user_character_map__character_fk (character_id ASC),
	FAMILY "primary" (user_id, character_id)
);

ALTER TABLE corporations ADD CONSTRAINT corporation_alliance_alliance_id_fk FOREIGN KEY (alliance_id) REFERENCES alliances(alliance_id);
ALTER TABLE characters ADD CONSTRAINT character_corporation_corporation_id_fk FOREIGN KEY (corporation_id) REFERENCES corporations(corporation_id);
ALTER TABLE alliance_character_leadership_role_map ADD CONSTRAINT alliance_leadership__character_fk FOREIGN KEY (character_id) REFERENCES characters(character_id);
ALTER TABLE alliance_character_leadership_role_map ADD CONSTRAINT alliance_leadership__role_fk FOREIGN KEY (role_id) REFERENCES roles(role_id);
ALTER TABLE alliance_character_leadership_role_map ADD CONSTRAINT alliance_leadership__alliance_fk FOREIGN KEY (alliance_id) REFERENCES alliances(alliance_id);
ALTER TABLE alliance_corporation_role_map ADD CONSTRAINT alliance_corporation_role_map__corporation_fk FOREIGN KEY (corporation_id) REFERENCES corporations(corporation_id);
ALTER TABLE alliance_corporation_role_map ADD CONSTRAINT alliance_corporation_role_map__role_fk FOREIGN KEY (role_id) REFERENCES roles(role_id);
ALTER TABLE alliance_corporation_role_map ADD CONSTRAINT alliance_corporation_role_map__alliance_fk FOREIGN KEY (alliance_id) REFERENCES alliances(alliance_id);
ALTER TABLE alliance_role_map ADD CONSTRAINT alliance_role_map__alliance_fk FOREIGN KEY (alliance_id) REFERENCES alliances(alliance_id);
ALTER TABLE alliance_role_map ADD CONSTRAINT alliance_role_map__role_fk FOREIGN KEY (role_id) REFERENCES roles(role_id);
ALTER TABLE authentication_codes ADD CONSTRAINT authentication_code_character_character_id_fk FOREIGN KEY (character_id) REFERENCES characters(character_id);
ALTER TABLE authentication_scope_character_map ADD CONSTRAINT scope_character_map__scope_fk FOREIGN KEY (authentication_scope_id) REFERENCES authentication_scopes(authentication_scope_id);
ALTER TABLE authentication_scope_character_map ADD CONSTRAINT scope_character_map__character_fk FOREIGN KEY (character_id) REFERENCES characters(character_id);
ALTER TABLE character_role_map ADD CONSTRAINT character_role_map__role_fk FOREIGN KEY (role_id) REFERENCES roles(role_id);
ALTER TABLE character_role_map ADD CONSTRAINT character_role_map__character_fk FOREIGN KEY (character_id) REFERENCES characters(character_id);
ALTER TABLE corp_character_leadership_role_map ADD CONSTRAINT leadership_role__character_fk FOREIGN KEY (character_id) REFERENCES characters(character_id);
ALTER TABLE corp_character_leadership_role_map ADD CONSTRAINT leadership_role__role_fk FOREIGN KEY (role_id) REFERENCES roles(role_id);
ALTER TABLE corp_character_leadership_role_map ADD CONSTRAINT leadership_role__corporation_fk FOREIGN KEY (corporation_id) REFERENCES corporations(corporation_id);
ALTER TABLE corporation_role_map ADD CONSTRAINT corporation_role_map__corporation_fk FOREIGN KEY (corporation_id) REFERENCES corporations(corporation_id);
ALTER TABLE corporation_role_map ADD CONSTRAINT corporation_role_map__role_fk FOREIGN KEY (role_id) REFERENCES roles(role_id);
ALTER TABLE user_character_map ADD CONSTRAINT user_character_map__character_fk FOREIGN KEY (character_id) REFERENCES characters(character_id);
ALTER TABLE user_character_map ADD CONSTRAINT user_character_map__user_fk FOREIGN KEY (user_id) REFERENCES users(user_id);

-- Validate foreign key constraints. These can fail if there was unvalidated data during the dump.
ALTER TABLE corporations VALIDATE CONSTRAINT corporation_alliance_alliance_id_fk;
ALTER TABLE characters VALIDATE CONSTRAINT character_corporation_corporation_id_fk;
ALTER TABLE alliance_character_leadership_role_map VALIDATE CONSTRAINT alliance_leadership__character_fk;
ALTER TABLE alliance_character_leadership_role_map VALIDATE CONSTRAINT alliance_leadership__role_fk;
ALTER TABLE alliance_character_leadership_role_map VALIDATE CONSTRAINT alliance_leadership__alliance_fk;
ALTER TABLE alliance_corporation_role_map VALIDATE CONSTRAINT alliance_corporation_role_map__corporation_fk;
ALTER TABLE alliance_corporation_role_map VALIDATE CONSTRAINT alliance_corporation_role_map__role_fk;
ALTER TABLE alliance_corporation_role_map VALIDATE CONSTRAINT alliance_corporation_role_map__alliance_fk;
ALTER TABLE alliance_role_map VALIDATE CONSTRAINT alliance_role_map__alliance_fk;
ALTER TABLE alliance_role_map VALIDATE CONSTRAINT alliance_role_map__role_fk;
ALTER TABLE authentication_codes VALIDATE CONSTRAINT authentication_code_character_character_id_fk;
ALTER TABLE authentication_scope_character_map VALIDATE CONSTRAINT scope_character_map__scope_fk;
ALTER TABLE authentication_scope_character_map VALIDATE CONSTRAINT scope_character_map__character_fk;
ALTER TABLE character_role_map VALIDATE CONSTRAINT character_role_map__role_fk;
ALTER TABLE character_role_map VALIDATE CONSTRAINT character_role_map__character_fk;
ALTER TABLE corp_character_leadership_role_map VALIDATE CONSTRAINT leadership_role__character_fk;
ALTER TABLE corp_character_leadership_role_map VALIDATE CONSTRAINT leadership_role__role_fk;
ALTER TABLE corp_character_leadership_role_map VALIDATE CONSTRAINT leadership_role__corporation_fk;
ALTER TABLE corporation_role_map VALIDATE CONSTRAINT corporation_role_map__corporation_fk;
ALTER TABLE corporation_role_map VALIDATE CONSTRAINT corporation_role_map__role_fk;
ALTER TABLE user_character_map VALIDATE CONSTRAINT user_character_map__character_fk;
ALTER TABLE user_character_map VALIDATE CONSTRAINT user_character_map__user_fk;
