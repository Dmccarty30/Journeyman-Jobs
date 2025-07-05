import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { ComponentPropertyType, Paint, Vector } from '@figma/rest-api-spec';
export { startServer } from './cli.js';

interface SimplifiedLayout {
    mode: "none" | "row" | "column";
    justifyContent?: "flex-start" | "flex-end" | "center" | "space-between" | "baseline" | "stretch";
    alignItems?: "flex-start" | "flex-end" | "center" | "space-between" | "baseline" | "stretch";
    alignSelf?: "flex-start" | "flex-end" | "center" | "stretch";
    wrap?: boolean;
    gap?: string;
    locationRelativeToParent?: {
        x: number;
        y: number;
    };
    dimensions?: {
        width?: number;
        height?: number;
        aspectRatio?: number;
    };
    padding?: string;
    sizing?: {
        horizontal?: "fixed" | "fill" | "hug";
        vertical?: "fixed" | "fill" | "hug";
    };
    overflowScroll?: ("x" | "y")[];
    position?: "absolute";
}

interface SimplifiedComponentDefinition {
    id: string;
    key: string;
    name: string;
    componentSetId?: string;
}
interface SimplifiedComponentSetDefinition {
    id: string;
    key: string;
    name: string;
    description?: string;
}

type StyleId = `${string}_${string}` & {
    __brand: "StyleId";
};

type SimplifiedStroke = {
    colors: SimplifiedFill[];
    strokeWeight?: string;
    strokeDashes?: number[];
    strokeWeights?: string;
};

type SimplifiedEffects = {
    boxShadow?: string;
    filter?: string;
    backdropFilter?: string;
    textShadow?: string;
};

type TextStyle = Partial<{
    fontFamily: string;
    fontWeight: number;
    fontSize: number;
    lineHeight: string;
    letterSpacing: string;
    textCase: string;
    textAlignHorizontal: string;
    textAlignVertical: string;
}>;
type StyleTypes = TextStyle | SimplifiedFill[] | SimplifiedLayout | SimplifiedStroke | SimplifiedEffects | string;
type GlobalVars = {
    styles: Record<StyleId, StyleTypes>;
};
interface SimplifiedDesign {
    name: string;
    lastModified: string;
    thumbnailUrl: string;
    nodes: SimplifiedNode[];
    components: Record<string, SimplifiedComponentDefinition>;
    componentSets: Record<string, SimplifiedComponentSetDefinition>;
    globalVars: GlobalVars;
}
interface ComponentProperties {
    name: string;
    value: string;
    type: ComponentPropertyType;
}
interface SimplifiedNode {
    id: string;
    name: string;
    type: string;
    boundingBox?: BoundingBox;
    text?: string;
    textStyle?: string;
    fills?: string;
    styles?: string;
    strokes?: string;
    effects?: string;
    opacity?: number;
    borderRadius?: string;
    layout?: string;
    componentId?: string;
    componentProperties?: ComponentProperties[];
    children?: SimplifiedNode[];
}
interface BoundingBox {
    x: number;
    y: number;
    width: number;
    height: number;
}
type CSSRGBAColor = `rgba(${number}, ${number}, ${number}, ${number})`;
type CSSHexColor = `#${string}`;
type SimplifiedFill = {
    type?: Paint["type"];
    hex?: string;
    rgba?: string;
    opacity?: number;
    imageRef?: string;
    scaleMode?: string;
    gradientHandlePositions?: Vector[];
    gradientStops?: {
        position: number;
        color: ColorValue | string;
    }[];
} | CSSRGBAColor | CSSHexColor;
interface ColorValue {
    hex: string;
    opacity: number;
}

type FigmaAuthOptions = {
    figmaApiKey: string;
    figmaOAuthToken: string;
    useOAuth: boolean;
};
type FetchImageParams = {
    nodeId: string;
    fileName: string;
    fileType: "png" | "svg";
};
type FetchImageFillParams = Omit<FetchImageParams, "fileType"> & {
    imageRef: string;
};
declare class FigmaService {
    private readonly apiKey;
    private readonly oauthToken;
    private readonly useOAuth;
    private readonly baseUrl;
    constructor({ figmaApiKey, figmaOAuthToken, useOAuth }: FigmaAuthOptions);
    private request;
    getImageFills(fileKey: string, nodes: FetchImageFillParams[], localPath: string): Promise<string[]>;
    getImages(fileKey: string, nodes: FetchImageParams[], localPath: string, pngScale: number, svgOptions: {
        outlineText: boolean;
        includeId: boolean;
        simplifyStroke: boolean;
    }): Promise<string[]>;
    getFile(fileKey: string, depth?: number | null): Promise<SimplifiedDesign>;
    getNode(fileKey: string, nodeId: string, depth?: number | null): Promise<SimplifiedDesign>;
}

type CreateServerOptions = {
    isHTTP?: boolean;
    outputFormat?: "yaml" | "json";
};
declare function createServer(authOptions: FigmaAuthOptions, { isHTTP, outputFormat }?: CreateServerOptions): McpServer;

interface ServerConfig {
    auth: FigmaAuthOptions;
    port: number;
    outputFormat: "yaml" | "json";
    configSources: {
        figmaApiKey: "cli" | "env";
        figmaOAuthToken: "cli" | "env" | "none";
        port: "cli" | "env" | "default";
        outputFormat: "cli" | "env" | "default";
        envFile: "cli" | "default";
    };
}
declare function getServerConfig(isStdioMode: boolean): ServerConfig;

export { FigmaService, type SimplifiedDesign, createServer, getServerConfig };
