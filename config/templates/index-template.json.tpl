{
  "index_patterns": [
    "cloudflare-*"
  ],
  "mappings": {
    "properties": {
      "@timestamp": {
        "type": "date"
      },
      "agent": {
        "properties": {
          "ephemeral_id": {
            "ignore_above": 1024,
            "type": "keyword"
          },
          "hostname": {
            "ignore_above": 1024,
            "type": "keyword"
          },
          "id": {
            "ignore_above": 1024,
            "type": "keyword"
          },
          "name": {
            "ignore_above": 1024,
            "type": "keyword"
          },
          "type": {
            "ignore_above": 1024,
            "type": "keyword"
          },
          "version": {
            "ignore_above": 1024,
            "type": "keyword"
          }
        }
      },
      "cloudflare": {
        "properties": {
          "@timestamp": {
            "path": "@timestamp",
            "type": "alias"
          },
          "@version": {
            "type": "keyword"
          },
          "CacheCacheStatus": {
            "type": "keyword"
          },
          "CacheResponseBytes": {
            "type": "long"
          },
          "CacheResponseStatus": {
            "type": "long"
          },
          "CacheTieredFill": {
            "type": "boolean"
          },
          "ClientASN": {
            "type": "long"
          },
          "ClientCountry": {
            "type": "keyword"
          },
          "ClientDeviceType": {
            "type": "keyword"
          },
          "ClientIP": {
            "type": "ip"
          },
          "ClientIPClass": {
            "fields": {
              "keyword": {
                "ignore_above": 256,
                "type": "keyword"
              }
            },
            "type": "text"
          },
          "ClientRequestBytes": {
            "type": "long"
          },
          "ClientRequestHost": {
            "type": "keyword"
          },
          "ClientRequestMethod": {
            "type": "keyword"
          },
          "ClientRequestPath": {
            "fields": {
              "keyword": {
                "ignore_above": 256,
                "type": "keyword"
              }
            },
            "type": "text"
          },
          "ClientRequestProtocol": {
            "fields": {
              "keyword": {
                "ignore_above": 256,
                "type": "keyword"
              }
            },
            "type": "text"
          },
          "ClientRequestReferer": {
            "fields": {
              "keyword": {
                "ignore_above": 512,
                "type": "keyword"
              }
            },
            "type": "text"
          },
          "ClientRequestURI": {
            "fields": {
              "keyword": {
                "ignore_above": 512,
                "type": "keyword"
              }
            },
            "type": "text"
          },
          "ClientRequestUserAgent": {
            "fields": {
              "keyword": {
                "ignore_above": 512,
                "type": "keyword"
              }
            },
            "type": "text"
          },
          "ClientSSLCipher": {
            "fields": {
              "keyword": {
                "ignore_above": 256,
                "type": "keyword"
              }
            },
            "type": "text"
          },
          "ClientSSLProtocol": {
            "fields": {
              "keyword": {
                "ignore_above": 256,
                "type": "keyword"
              }
            },
            "type": "text"
          },
          "ClientSrcPort": {
            "type": "long"
          },
          "EdgeColoID": {
            "type": "long"
          },
          "EdgeDuration": {
            "type": "long"
          },
          "EdgeEndTime": {
            "type": "date"
          },
          "EdgeEndTimestamp": {
            "type": "long"
          },
          "EdgePathingOp": {
            "type": "keyword"
          },
          "EdgePathingSrc": {
            "type": "keyword"
          },
          "EdgePathingStatus": {
            "type": "keyword"
          },
          "EdgeRateLimitAction": {
            "fields": {
              "keyword": {
                "ignore_above": 256,
                "type": "keyword"
              }
            },
            "type": "text"
          },
          "EdgeRateLimitID": {
            "type": "long"
          },
          "EdgeRequestHost": {
            "type": "keyword"
          },
          "EdgeResponseBytes": {
            "type": "long"
          },
          "EdgeResponseCompressionRatio": {
            "type": "float"
          },
          "EdgeResponseContentType": {
            "fields": {
              "keyword": {
                "ignore_above": 256,
                "type": "keyword"
              }
            },
            "type": "text"
          },
          "EdgeResponseStatus": {
            "type": "long"
          },
          "EdgeServerIP": {
            "type": "keyword"
          },
          "EdgeStartTime": {
            "type": "date"
          },
          "EdgeStartTimestamp": {
            "type": "long"
          },
          "OriginIP": {
            "type": "keyword"
          },
          "OriginResponseBytes": {
            "type": "long"
          },
          "OriginResponseHTTPExpires": {
            "fields": {
              "keyword": {
                "ignore_above": 256,
                "type": "keyword"
              }
            },
            "type": "text"
          },
          "OriginResponseHTTPLastModified": {
            "fields": {
              "keyword": {
                "ignore_above": 256,
                "type": "keyword"
              }
            },
            "type": "text"
          },
          "OriginResponseStatus": {
            "type": "long"
          },
          "OriginResponseTime": {
            "type": "long"
          },
          "OriginSSLProtocol": {
            "fields": {
              "keyword": {
                "ignore_above": 256,
                "type": "keyword"
              }
            },
            "type": "text"
          },
          "ParentRayID": {
            "type": "keyword"
          },
          "RayID": {
            "type": "keyword"
          },
          "SecurityLevel": {
            "type": "keyword"
          },
          "UserAgent": {
            "properties": {
              "build": {
                "type": "keyword"
              },
              "device": {
                "type": "keyword"
              },
              "major": {
                "type": "keyword"
              },
              "minor": {
                "type": "keyword"
              },
              "name": {
                "type": "keyword"
              },
              "os": {
                "fields": {
                  "keyword": {
                    "ignore_above": 256,
                    "type": "keyword"
                  }
                },
                "type": "text"
              },
              "os_major": {
                "type": "keyword"
              },
              "os_minor": {
                "type": "keyword"
              },
              "os_name": {
                "fields": {
                  "keyword": {
                    "ignore_above": 256,
                    "type": "keyword"
                  }
                },
                "type": "text"
              },
              "patch": {
                "type": "keyword"
              }
            }
          },
          "WAFAction": {
            "fields": {
              "keyword": {
                "ignore_above": 256,
                "type": "keyword"
              }
            },
            "type": "text"
          },
          "WAFFlags": {
            "fields": {
              "keyword": {
                "ignore_above": 256,
                "type": "keyword"
              }
            },
            "type": "text"
          },
          "WAFMatchedVar": {
            "fields": {
              "keyword": {
                "ignore_above": 256,
                "type": "keyword"
              }
            },
            "type": "text"
          },
          "WAFProfile": {
            "fields": {
              "keyword": {
                "ignore_above": 256,
                "type": "keyword"
              }
            },
            "type": "text"
          },
          "WAFRuleID": {
            "fields": {
              "keyword": {
                "ignore_above": 256,
                "type": "keyword"
              }
            },
            "type": "text"
          },
          "WAFRuleMessage": {
            "fields": {
              "keyword": {
                "ignore_above": 256,
                "type": "keyword"
              }
            },
            "type": "text"
          },
          "WorkerCPUTime": {
            "type": "long"
          },
          "WorkerStatus": {
            "fields": {
              "keyword": {
                "ignore_above": 256,
                "type": "keyword"
              }
            },
            "type": "text"
          },
          "WorkerSubrequest": {
            "type": "boolean"
          },
          "WorkerSubrequestCount": {
            "type": "long"
          },
          "ZoneID": {
            "type": "long"
          },
          "message": {
            "fields": {
              "keyword": {
                "ignore_above": 256,
                "type": "keyword"
              }
            },
            "type": "text"
          }
        }
      },
      "extra": {
        "properties": {
          "geoip": {
            "properties": {
              "city_name": {
                "type": "text",
                "fields": {
                  "keyword": {
                    "type": "keyword",
                    "ignore_above": 256
                  }
                }
              },
              "continent_name": {
                "type": "text",
                "fields": {
                  "keyword": {
                    "type": "keyword",
                    "ignore_above": 256
                  }
                }
              },
              "country_iso_code": {
                "type": "text",
                "fields": {
                  "keyword": {
                    "type": "keyword",
                    "ignore_above": 256
                  }
                }
              },
              "country_name": {
                "type": "text",
                "fields": {
                  "keyword": {
                    "type": "keyword",
                    "ignore_above": 256
                  }
                }
              },
              "location": {
                "type": "geo_point"
              },
              "region_iso_code": {
                "type": "text",
                "fields": {
                  "keyword": {
                    "type": "keyword",
                    "ignore_above": 256
                  }
                }
              },
              "region_name": {
                "type": "text",
                "fields": {
                  "keyword": {
                    "type": "keyword",
                    "ignore_above": 256
                  }
                }
              },
              "timezone": {
                "type": "text",
                "fields": {
                  "keyword": {
                    "type": "keyword",
                    "ignore_above": 256
                  }
                }
              }
            }
          },
          "user_agent": {
            "properties": {
              "device": {
                "properties": {
                  "name": {
                    "type": "text",
                    "fields": {
                      "keyword": {
                        "type": "keyword",
                        "ignore_above": 256
                      }
                    }
                  }
                }
              },
              "name": {
                "type": "text",
                "fields": {
                  "keyword": {
                    "type": "keyword",
                    "ignore_above": 256
                  }
                }
              },
              "original": {
                "type": "text",
                "fields": {
                  "keyword": {
                    "type": "keyword",
                    "ignore_above": 256
                  }
                }
              },
              "os": {
                "properties": {
                  "full": {
                    "type": "text",
                    "fields": {
                      "keyword": {
                        "type": "keyword",
                        "ignore_above": 256
                      }
                    }
                  },
                  "name": {
                    "type": "text",
                    "fields": {
                      "keyword": {
                        "type": "keyword",
                        "ignore_above": 256
                      }
                    }
                  },
                  "version": {
                    "type": "text",
                    "fields": {
                      "keyword": {
                        "type": "keyword",
                        "ignore_above": 256
                      }
                    }
                  }
                }
              },
              "version": {
                "type": "text",
                "fields": {
                  "keyword": {
                    "type": "keyword",
                    "ignore_above": 256
                  }
                }
              }
            }
          }
        }
      }
    }
  },
  "settings": {
    "index": {
      "number_of_replicas": "0",
      "number_of_shards": "1",
      "refresh_interval": "15s"
    }
  }
}
