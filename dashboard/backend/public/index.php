<?php
/**
 * DevOps Dashboard - Backend API Entry Point
 */

// Set error reporting
error_reporting(E_ALL);
ini_set('display_errors', 0);

// Set headers
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Get request URI and method
$request_uri = $_SERVER['REQUEST_URI'];
$request_method = $_SERVER['REQUEST_METHOD'];

// Remove query string
$path = parse_url($request_uri, PHP_URL_PATH);

// Remove /api prefix if exists
$path = preg_replace('#^/api#', '', $path);

// Route handling
$routes = [
    'GET /v1/health' => 'healthCheck',
    'GET /v1/agents' => 'listAgents',
    'POST /v1/agents/register' => 'registerAgent',
    'POST /v1/agents/heartbeat' => 'agentHeartbeat',
];

// Find matching route
$route_key = $request_method . ' ' . $path;
$handler = null;

foreach ($routes as $route => $handler_name) {
    $pattern = '#^' . str_replace(['/', ':id'], ['\/', '([^\/]+)'], $route) . '$#';
    if (preg_match($pattern, $request_method . ' ' . $path)) {
        $handler = $handler_name;
        break;
    }
}

// If no route found, try exact match
if (!$handler && isset($routes[$route_key])) {
    $handler = $routes[$route_key];
}

// Execute handler
if ($handler && function_exists($handler)) {
    try {
        $handler();
    } catch (Exception $e) {
        http_response_code(500);
        echo json_encode([
            'status' => 'error',
            'message' => $e->getMessage()
        ]);
    }
} else {
    http_response_code(404);
    echo json_encode([
        'status' => 'error',
        'message' => 'Endpoint not found',
        'path' => $path,
        'method' => $request_method
    ]);
}

// Handler functions
function healthCheck() {
    http_response_code(200);
    echo json_encode([
        'status' => 'ok',
        'message' => 'DevOps Dashboard API is running',
        'version' => '1.0.0',
        'timestamp' => date('c')
    ]);
}

function listAgents() {
    // TODO: Get from database
    http_response_code(200);
    echo json_encode([
        'status' => 'ok',
        'agents' => []
    ]);
}

function registerAgent() {
    // Get JSON input
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (!$input || !isset($input['name'])) {
        http_response_code(400);
        echo json_encode([
            'status' => 'error',
            'message' => 'Missing required field: name'
        ]);
        return;
    }
    
    $name = $input['name'];
    $ip = $input['ip'] ?? $_SERVER['REMOTE_ADDR'];
    
    // Generate token
    $token = bin2hex(random_bytes(32));
    
    // TODO: Save to database
    // For now, just return token
    
    http_response_code(200);
    echo json_encode([
        'status' => 'ok',
        'message' => 'Agent registered successfully',
        'data' => [
            'name' => $name,
            'ip' => $ip,
            'token' => $token,
            'agent_id' => bin2hex(random_bytes(16))
        ]
    ]);
}

function agentHeartbeat() {
    // Get JSON input
    $input = json_decode(file_get_contents('php://input'), true);
    
    // Get token from header or input
    $token = null;
    $headers = getallheaders();
    if (isset($headers['Authorization'])) {
        $token = str_replace('Bearer ', '', $headers['Authorization']);
    } elseif (isset($input['token'])) {
        $token = $input['token'];
    }
    
    if (!$token) {
        http_response_code(401);
        echo json_encode([
            'status' => 'error',
            'message' => 'Missing authentication token'
        ]);
        return;
    }
    
    // TODO: Verify token and update agent status in database
    
    http_response_code(200);
    echo json_encode([
        'status' => 'ok',
        'message' => 'Heartbeat received',
        'timestamp' => date('c')
    ]);
}
