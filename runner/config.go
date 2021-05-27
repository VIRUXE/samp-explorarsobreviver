package runner

import (
	"time"

	"go.uber.org/zap/zapcore"
)

type Config struct {
	Production           bool          `envconfig:"PRODUCTION"         default:"false"`
	LogLevel             zapcore.Level `envconfig:"LOG_LEVEL"          default:"info"`
	Settings             string        `envconfig:"SETTINGS_OVERRIDE"`
	Restart              time.Duration `envconfig:"AUTO_RESTART_TIME"  default:"1h"`
	AutoBuild            bool          `envconfig:"AUTO_BUILD"         default:"false"`
	DiscordToken         string        `envconfig:"DISCORD_TOKEN"      default:"ODQ3MTcwMjcwMDk4NzUxNDkw.YK6KzA.3Z2wcazEuXGDl94ptQPmJI6nmjw"`
	DiscordChannelInfo   string        `envconfig:"DISCORD_CHANNEL_INFO"    default:"846031149285638195"`
	DiscordChannelErrors string        `envconfig:"DISCORD_CHANNEL_ERRORS"    default:"846147922332745728"`
	RconPassword         string        `envconfig:"RCON_PASSWORD"      default:"144"`
}
