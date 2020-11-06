# Copyright 2020 The Pigweed Authors
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License. You may obtain a copy of
# the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations under
# the License.
"""Utilities for Sample Project development."""

import setuptools  # type: ignore

setuptools.setup(
    name='sample_project_tools',
    version='0.0.1',
    description=__doc__,
    packages=setuptools.find_packages(),
    install_requires=[],
    package_data={'sample_project_tools': ['py.typed']},
    zip_safe=False,
)
