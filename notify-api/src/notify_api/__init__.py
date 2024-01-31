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
"""The Notify API service.

This module is the API for the BC Registries Notify application.
"""
import os

from flask import Flask
from flask_migrate import Migrate

from notify_api.config import config
from notify_api.models import db
from notify_api.resources import v1_endpoint, v2_endpoint
from notify_api.translations import babel
from notify_api.utils.auth import jwt

# from notify_api.utils.logging import setup_logging

# setup_logging(os.path.join(os.path.abspath(os.path.dirname(__file__)), "logging.conf"))


def create_app(run_mode=os.getenv("DEPLOYMENT_ENV", "production"), **kwargs):
    """Return a configured Flask App using the Factory method."""
    app = Flask(__name__)
    app.config.from_object(config[run_mode])
    app.url_map.strict_slashes = False

    db.init_app(app)
    Migrate(app, db)
    babel.init_app(app)
    v1_endpoint.init_app(app)
    v2_endpoint.init_app(app)

    setup_jwt_manager(app, jwt)

    return app


def setup_jwt_manager(app, jwt_manager):
    """Use flask app to configure the JWTManager to work for a particular Realm."""

    def get_roles(a_dict):
        return a_dict["realm_access"]["roles"]  # pragma: no cover

    app.config["JWT_ROLE_CALLBACK"] = get_roles

    jwt_manager.init_app(app)
