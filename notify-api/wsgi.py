# Copyright © 2019 Province of British Columbia
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
"""Provides the WSGI entry point for running the application."""
import os
import signal
import sys
from types import FrameType

from flask_migrate import Migrate

from notify_api import create_app, db
from notify_api.utils.logging import flush, logger

app = create_app()  # pylint: disable=invalid-name
migrate = Migrate(app, db)


def shutdown_handler(signal_int: int, frame: FrameType) -> None:
    """Shutdown Handler."""
    logger.info(f"Caught Signal {signal.strsignal(signal_int)}")

    flush()

    # Safely exit program
    sys.exit(0)


if __name__ == "__main__":
    # Running application locally, outside of a Google Cloud Environment

    # handles Ctrl-C termination
    signal.signal(signal.SIGINT, shutdown_handler)

    server_port = os.environ.get("PORT", "8080")
    app.run(debug=False, threaded=False, port=server_port, host="0.0.0.0")
else:
    # handles Cloud Run container termination
    signal.signal(signal.SIGTERM, shutdown_handler)
