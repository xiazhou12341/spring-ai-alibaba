/*
 * Copyright 2025 the original author or authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      https://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.alibaba.cloud.ai.studio.runtime.domain.plugin;

import lombok.Data;

import java.io.Serializable;

/**
 * Example usage for a tool.
 *
 * @since 1.0.0.3
 */
@Data
public class ToolExample implements Serializable {

	/**
	 * Request parameters as JSON string
	 */
	private String request;

	/**
	 * Response result as JSON string
	 */
	private String response;

}
