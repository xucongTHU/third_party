// Copyright 2021 The T3CAIC.COM Authors. All Rights Reserved.

#pragma once

#include <google/protobuf/message.h>
#include <string>

namespace apollo {

bool loadFromFile(const std::string& filename, ::google::protobuf::Message* message);

bool saveToFile(const std::string& filename, const ::google::protobuf::Message& message);

}  // namespace smartcar::common::proto
